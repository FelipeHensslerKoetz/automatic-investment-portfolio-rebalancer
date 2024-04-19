# frozen_string_literal: true
class ApiConstraints
  attr_reader :version, :default

  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    return true if default && !req.headers['Accept'].include?("application/vnd.blog.v")

    req.headers['Accept'].include?("application/vnd.blog.v#{version}")
  end
end
