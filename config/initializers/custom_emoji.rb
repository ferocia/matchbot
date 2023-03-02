# frozen_string_literal: true

require 'gemoji'

# Custom Emoji :roll_eyes:
Emoji.create('9ball') do |c|
  c.image_filename = 'https://emoji.slack-edge.com/T024P5CCV/9ball/c187be4ee5ea0acb.png'
end

Emoji.create('smash') do |c|
  c.image_filename = 'https://emoji.slack-edge.com/T024P5CCV/smash/2e9ddf3f01b420ce.png'
end

Emoji.create('kart') do |c|
  c.image_filename = 'https://emoji.slack-edge.com/T024P5CCV/kart/0ae70064c246aef8.jpg'
end

Emoji.create('towerfall') do |c|
  c.image_filename = 'https://emoji.slack-edge.com/T024P5CCV/towerfall/6dbff25586e59594.png'
end
