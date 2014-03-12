class Exe
  def initialize command
    @command = command
  end
  attr_reader :command, :output, :errors

  def run close = true
    self.status = Open4.popen4 command do |p, i, o, e|
      self.pioe = [p, i, o, e]

      self.output = o.read
      self.errors = e.read

      [i, o, e].map(&:close) if close
    end
    self
  end

  private

  attr_writer :output, :errors

  def pioe= pioe
    @pid, @stdin, @stdout, @stderr = pioe
  end
  attr_reader :pid, :stdin, :stdout, :stderr
  attr_accessor :status
end
