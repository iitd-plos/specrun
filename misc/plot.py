#!/usr/bin/python

import argparse
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import collections
import random
from operator import itemgetter
import pprint

def avg_y_vals(data):
  ret = {}
  for x, y in data:
    if x not in ret:
      ret[x] = (y, 1)
    else:
      ret[x] = ((ret[x][0] * ret[x][1] + y)/(ret[x][1]+1), ret[x][1]+1)
  arr = []
  for a in ret:
    arr.append((a, ret[a][0]))
  return arr
def split_pair_to_arr(data):
  ret = [], []
  for d in data:
    ret[0].append(d[0])
    ret[1].append(d[1])
  return ret

def ignore_small_values(stats):
  ret = {}
  for bench in stats:
    for c in stats[bench]:
      if stats[bench][c] < 0.5:
        continue
      if bench not in ret:
        ret[bench] = {}
      ret[bench][c] = stats[bench][c]
  return ret

def show_string(cat):
  return cat
  if cat == 'compcert':
    return 'ctests'
  if cat == 'gcc48.O0':
    return 'gcc-O0'
  if cat == 'gcc48.O2':
    return 'gcc-O2'
  if cat == 'gcc48.O3':
    return 'gcc-O3'
  if cat == 'icc.O0':
    return 'icc-O0'
  if cat == 'icc.O2':
    return 'icc-O2'
  if cat == 'icc.O3':
    return 'icc-O3'
  if cat == 'ccomp.O0':
    return 'ccomp-O0'
  if cat == 'ccomp.O2':
    return 'ccomp-O2'
  if cat == 'clang36.O0':
    return 'clang-O0'
  if cat == 'clang36.O2':
    return 'clang-O2'
  if cat == 'clang36.O3':
    return 'clang-O3'
  if cat == 'gcc48-i386-O0-soft-float':
    return 'gcc-O0'
  if cat == 'gcc48-i386-O2-soft-float':
    return 'gcc-O2'
  if cat == 'gcc48-i386-O3-soft-float':
    return 'gcc-O3'
  if cat == 'clang36-i386-O0-soft-float':
    return 'clang-O0'
  if cat == 'clang36-i386-O2-soft-float':
    return 'clang-O2'
  if cat == 'clang36-i386-O3-soft-float':
    return 'clang-O3'
  if cat == 'icc-i386-O0-soft-float':
    return 'icc-O0'
  if cat == 'icc-i386-O2-soft-float':
    return 'icc-O2'
  if cat == 'icc-i386-O3-soft-float':
    return 'icc-O3'
  if cat == 'ccomp-i386-O0-soft-float':
    return 'ccomp-O0'
  if cat == 'ccomp-i386-O2-soft-float':
    return 'ccomp-O2'
  return cat

def get_bench_nr(bench):
  order_benches = [
    'specrand998', 
    'specrand999', 
    'specrand.998', 
    'specrand.999', 
    'mcf', 
    'bzip2', 
    'ctests', 
    'compcert', 
    'gzip', 
    'sjeng', 
    'astar',
    'parser', 
    'gap', 
    ]
  for (i, b) in enumerate(order_benches):
    if b == bench:
      return i
  #assert False
  return 100

def get_cat_nr_main(cat):
  order_cat = ['gcc2', 'clang2', 'icc2', 'ccomp2', 'gcc3', 'clang3', 'icc3']
  for (i, c) in enumerate(order_cat):
    if c == show_string(cat):
      return i
  #assert False
  return 100

def get_bench_cat_weight((b, c)):
  return 100*get_bench_nr(b) + get_cat_nr_main(c)

def compare_bench_cat(bc1, bc2):
  return cmp(get_bench_cat_weight(bc1), get_bench_cat_weight(bc2))

def get_group_cats(results):
  ret = []
  for (group, cat, loop) in results:
    if cat.startswith('cg'):
      continue
    if group == 'astar':
      continue
    if (group, cat) not in ret:
      ret.append((group, cat))
  ret.sort(compare_bench_cat)
  return ret

def get_cats(results):
  ret = set()
  for (group, cat, loop) in results:
    if cat.startswith('cg'):
      continue
    if group == 'astar':
      continue
    if (group, cat) not in ret:
      ret.add(cat)
  return ret

def compute_percent(a, total):
  return a*100.0/total

def get_colors(count):
  colors = ['#bae4b3','#74c476','#fb6a4a','#cb181d', '#1a9641', '#a6d96a', '#fdae61', '#d7191c']
  assert(count <= len(colors))
  return colors[0:count]

def get_color(index):
  colors = ['#bae4b3','#74c476','#fb6a4a','#cb181d', '#1a9641', '#a6d96a', '#fdae61', '#d7191c']
  #assert(index < len(colors))
  return colors[index % len(colors)]

def ignore_bench(results_map, bench):
  ret = {}
  for k in results_map:
    if bench == k[0]:
      continue
    ret[k] = results_map[k]
  return ret

def ignore_comp(results_map, c):
  ret = {}
  for k in results_map:
    if c == k[1]:
      continue
    ret[k] = results_map[k]
  return ret

def mean(arr):
  return sum(arr)/len(arr)

def percentile(arr, percent):
  return arr[len(arr)*percent/100]

  order_cat = ['gcc-O0', 'llvm-O0', 'icc-O0', 'ccomp-O0', 'gcc-O2', 'llvm-O2', 'icc-O2', 'ccomp-O2']
  for (i, c) in enumerate(order_cat):
    if c == cat:
      return i
  return 100

def get_cat_nr_perf(cat):
  order_cat = ['gcc-O0', 'llvm-O0', 'icc-O0', 'ccomp-O0', 'gcc-O2', 'llvm-O2', 'icc-O2', 'ccomp-O2']
  for (i, c) in enumerate(order_cat):
    if c == cat:
      return i
  return 100

def compare_bench(b1, b2):
  return cmp(get_bench_nr(b1), get_bench_nr(b2))

def compare_cat(c1, c2):
  return cmp(get_cat_nr_perf(c1), get_cat_nr_perf(c2))

def get_benches_comps(stats):
  benches = []
  comps = []
  for b in stats:
    benches.append(b)
    for c in stats[b]:
      if (c not in comps):# and (not c.endswith('0')):
        comps.append(c)
  #for b in benches:
  #  print '{} {}'.format(b, get_bench_nr(b))
  benches.sort(compare_bench)
  comps.sort(compare_cat)
  return (benches, comps)

def parse_compcert_perf_results(stats):
  stats['ctests'] = {}
  for line in open('../superopt/compcert.out'):
    [comp, val] = line.strip().split(' ')
    comp = show_string(comp)
    val = float(val)
    if comp not in stats['ctests']:
      stats['ctests'][comp] = val
    if val < stats['ctests']:
      stats['ctests'][comp] = val

def parse_spec_perf_results(stats, filename):
  #stats['ctests'] = {}
  data = []
  for line in open(filename):
    lst = line.strip().split(':')
    if len(lst) != 5:
      continue
    [bench, arg, comp, count, val] = lst
    val = float(val)
    data.append((bench.strip(), arg.strip(), show_string(comp.strip()), count.strip(), val))
  # sum different args
  stats1 = {}
  for k in data:
    (bench, arg, comp, count, val) = k
    new_k = (bench, comp, count)
    if new_k not in stats1:
      stats1[new_k] = val
    else:
      stats1[new_k] += val
  for k in stats1:
    (bench, comp, count) = k
    val = stats1[k]
    if bench not in stats:
      stats[bench] = {}
    if comp not in stats[bench]:
      stats[bench][comp] = val
    if val < stats[bench][comp]:
      stats[bench][comp] = val

def scale_stats(stats, comp):
  for bench in stats:
    ref = stats[bench][comp]
#    print ref
    for c in stats[bench]:
      curr = stats[bench][c]
      stats[bench][c] = ref/curr

def is_valid_comp_option(b, c):
  if b in ['astar', 'vortex', 'twolf', 'vortex', 'perlbmk'] and c.startswith('ccomp'):
    return False
  else: return True

def get_comp_values(stats, comp, benches):
  ret = []
  for b in benches:
    if not is_valid_comp_option(b, comp):
      ret.append(0)
    else:
      ret.append(stats[b][comp])
  return ret

def compute_avg_speedup(stats, benches, comps):
  count = 0
  tot = 0
  for b in benches:
    for c in comps:
      if not is_valid_comp_option(b, c):
        continue
      count += 1
      tot += stats[b][c]
  return tot/count

def ignore_benches_perf(stats, ignore_benches, keep_comp):
  ret = {}
  for k in stats:
    if k in ignore_benches:
      continue
    ret[k] = {}
    for c in stats[k]:
      if c not in keep_comp:
        continue
      ret[k][c] = stats[k][c]
  return ret

def perf_plots(comp_to_plot, ref_comp):
  stats = {}
  #parse_compcert_perf_results(stats)
  parse_spec_perf_results(stats, 'specrun2000.out')
  stats = ignore_small_values(stats)
  #parse_spec_perf_results(stats, '../superopt/specrun2006.out')
  stats = ignore_benches_perf(stats, ['gap', 'perlbmk'], comp_to_plot)
  pp = pprint.PrettyPrinter()
  pp.pprint(stats)
  scale_stats(stats, ref_comp)
  (benches, comps) = get_benches_comps(stats)
  print benches
  print comps
  
  avg_speedup = compute_avg_speedup(stats, benches, comps)
  print 'avg-speedup {}'.format(avg_speedup)

  n_benches = len(benches)
  n_comps = len(comps)
  ind = np.arange(n_benches)
  width = 1.0/(1.5+n_comps)

  fig = plt.figure(figsize=(11.5, 9))
  ax = fig.add_subplot(111)

  rectss = []
  for i,c in enumerate(comps):
    yvals = get_comp_values(stats, c, benches)
    rects = ax.bar(ind+width*i, yvals, width, color=get_color(i))
    rectss.append(rects)

  ax.axhline(y=avg_speedup, ls='--')
  plt.annotate('avg speedup: '+'{:.1f}'.format(avg_speedup), xy=(8.5, avg_speedup), xytext=(7, avg_speedup*1.5),  arrowprops=dict(arrowstyle="->"))
  ax.set_ylabel('Speedup relative to {}'.format(ref_comp))
  ax.set_xticks(ind+0.5-width/2.0)
  labels = map(show_string, benches)
  ax.set_xticklabels(labels, rotation=20)
  ax.legend(rectss, comps, ncol=2, loc='upper left')
  plt.tight_layout()
  plt.savefig('perf.pdf', dpi=100)

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  #parser.add_argument('--stats-only', help = "print only final stats", action='store_true')
  args = parser.parse_args()

  plt.rcParams['font.size'] = 11
  plt.rcParams['font.family'] = 'monospace'
  plt.rcParams['legend.fontsize'] = 9

  ref_comp = 'pgc-i386-O0'
  #comp_to_plot = ['gcc48-i386-O3', 'gcc48-i386-O3-soft-float', 'gcc48-i386-O2-soft-float']
  comp_to_plot = [
    'pgc-i386-O0', 
    'pgc-i386-O2', 
    'pgc-i386-O3', 
    'pgc-i386-O2-loop-opt-synth', 
    'pgc-i386-O3-loop-opt-synth', 
    'pgc-i386-Omem2reg', 'clang36-i386-O2']
  perf_plots(comp_to_plot, ref_comp)
