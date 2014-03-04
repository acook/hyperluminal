require_relative '../debug_info'

module DebugExplainer
  include DebugInfo
  def debug_explainer parser, result, input
    norm  = "\e[0m"
    red   = "\e[31m"
    green = "\e[32m"

    if result.nil? || parser.index != input.length then

      debug 'failed to parse input',
        input.inspect, header: "#{red}PARSE ERROR#{norm}"

      debug 'error location', input.inspect[1..-2]
      debug '', "#{' ' * parser.index.to_i}#{red}^#{norm}"
      debug '', "#{' ' * parser.failure_index.to_i}#{red}^#{norm}"

      debug 'input length', input.length
      debug 'last index', parser.index, newline: 1

      debug 'terminal failures', parser.terminal_failures.inspect
      debug 'failure reason', parser.failure_reason.inspect
      debug 'failure line', parser.failure_line
      debug 'failure column', parser.failure_column
      debug 'failure index', parser.failure_index

      debug newline: 1

      debug "#{red}OUTPUT#{norm}", result.inspect, newline: 1

    else

      debug "#{green}OUTPUT#{norm}",
        "\n\n#{result.inspect}", header: "#{green}SUCCESSFUL PARSE#{norm}"

    end
  end
end
