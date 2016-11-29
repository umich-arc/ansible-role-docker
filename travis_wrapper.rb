# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# poached from here: https://gist.github.com/roidrage/5238585
# Have to use a wrapper to get around travis 4mb log limit.

pid = Kernel.fork do
  `#{ARGV.join(' ')}`
  exit
end

trap(:CHLD) do
  print "\n"
  exit
end

loop do
  sleep 10
  begin
    Process.kill(0, pid)
    print '.'
  rescue Errno::ESRCH
    print "\n"
    exit 0
  end
end
