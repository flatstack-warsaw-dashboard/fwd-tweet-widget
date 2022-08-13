# frozen_string_literal: true

require_relative 'class_name_from_string'
require_relative 'slack_api'
require_relative 'slack_block/null'
require_relative 'slack_block/rich_text'

# Slack messages consist of different types of blocks. This is a Block factory.
# It rebuilds slack messages markdown from blocks.
class SlackBlock
  def initialize(slack_api = SlackApi.build)
    @api = slack_api
  end

  def build(block_data)
    block_class = begin
      block_type = ClassNameFromString.new(block_data['type']).to_s
      SlackBlock.const_get(block_type)
    rescue NameError
      puts "Unsupported block type: #{block_data['type']}"
      Null
    end
    block_class.new(element: block_data, api: @api)
  end
end
