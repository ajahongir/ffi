require File.expand_path(File.join(File.dirname(__FILE__), "bench_helper"))

module LibTest
  extend FFI::Library
  ffi_lib LIBTEST_PATH
  enum :foo, [ :a, :b, :c ]
  attach_function :ffi_bench, :bench_s32_v, [ :foo ], :void
  def self.rb_bench(i0); nil; end
end

puts "Benchmark [ enum ], :void performance, #{ITER}x calls"
10.times {
  puts Benchmark.measure {
    ITER.times { LibTest.ffi_bench(:a) }
  }
}
unless RUBY_PLATFORM == "java" && JRUBY_VERSION < "1.3.0"
  require 'dl'
  require 'dl/import'
  module LibTest
    if RUBY_VERSION >= "1.9.0"
      extend DL::Importer
    else
      extend DL::Importable
    end
    dlload LIBTEST_PATH
    extern "void bench_s32_v(int)"
  end
end

puts "Benchmark ruby method(1 arg)  performance, #{ITER}x calls"
10.times {
  puts Benchmark.measure {
    ITER.times { LibTest.rb_bench(:a) }
  }
}

