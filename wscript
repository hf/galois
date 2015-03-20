#!/bin/env python

top = '.'
out = 'build'

def options(opt):
  opt.load('compiler_cxx')

  opt.add_option('--with-tests', action='store_true', default=False, dest='galois_with_tests')

def configure(conf):
  conf.load('compiler_cxx')

  conf.env.GALOIS_WITH_TESTS = not (not conf.options.galois_with_tests)

  conf.recurse('galois')

  if conf.env.GALOIS_WITH_TESTS:
    conf.recurse('tests')

def build(bld):
  bld.recurse('galois')

  if bld.env.GALOIS_WITH_TESTS:
    bld.recurse('tests')

def test(ctx):
  print
  for test in ctx.path.ant_glob(out + '/tests/test_*'):
    print('T: ' + test.name)
    ctx.exec_command(test.abspath())

def tests(ctx):
  ctx.options.galois_with_tests = True

  from waflib import Options
  Options.commands = ['configure', 'build', 'test'] + Options.commands
