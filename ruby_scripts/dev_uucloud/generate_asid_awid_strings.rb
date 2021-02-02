require "securerandom"

ARGV[0].to_i.times do
  puts(SecureRandom.uuid.tr("-", ""))
end
