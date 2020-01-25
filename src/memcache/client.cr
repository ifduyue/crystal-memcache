require "socket"

module Memcache
  class Client
    # Open connection to memcached server, using text protocol
    def initialize(host = "localhost", port = 11211)
      @socket = TCPSocket.new(host, port)
    end

    # :nodoc:
    def finalize
      @socket.close if !@socket.nil?
    end

    # Set key/value pair
    #
    # returns: "STORED", "NOT_STORTED", "EXISTS" or "NOT_FOUNT"
    def set(key : String, value : String | Bytes, expire : Number = 0) : String
      @socket << "set #{key} 0 #{expire} #{value.bytesize}\r\n"
      case value
      when String
        @socket << value
      when Bytes
        @socket.write(value)
      end
      @socket << "\r\n"
      @socket.gets("\r\n", chomp: true).not_nil!
    end

    def add(key : String, value : String | Bytes, expire : Number = 0) : String
      @socket << "add #{key} 0 #{expire} #{value.bytesize}\r\n"
      case value
      when String
        @socket << value
      when Bytes
        @socket.write(value)
      end
      @socket << "\r\n"
      @socket.gets("\r\n", chomp: true).not_nil!
    end

    def replace(key : String, value : String | Bytes, expire : Number = 0) : String
      @socket << "replace #{key} 0 #{expire} #{value.bytesize}\r\n"
      case value
      when String
        @socket << value
      when Bytes
        @socket.write(value)
      end
      @socket << "\r\n"
      @socket.gets("\r\n", chomp: true).not_nil!
    end

    def append(key : String, value : String | Bytes, expire : Number = 0) : String
      @socket << "append #{key} 0 #{expire} #{value.bytesize}\r\n"
      case value
      when String
        @socket << value
      when Bytes
        @socket.write(value)
      end
      @socket << "\r\n"
      @socket.gets("\r\n", chomp: true).not_nil!
    end

    def prepend(key : String, value : String | Bytes, expire : Number = 0) : String
      @socket << "prepend #{key} 0 #{expire} #{value.bytesize}\r\n"
      case value
      when String
        @socket << value
      when Bytes
        @socket.write(value)
      end
      @socket << "\r\n"
      @socket.gets("\r\n", chomp: true).not_nil!
    end

    def get(key : String) : String?
      @socket << "get #{key}\r\n"
      header = @socket.gets("\r\n", chomp: true).not_nil!
      return nil if header == "END"
      headers = header.split
      bytesize = headers[3].to_u32
      value = @socket.read_string(bytesize)
      @socket.read_string(7) # discard "\r\nEND\r\n"
      value
    end

    def get_multi(keys : Array(String) | Tuple) : Hash(String, String?)
      result = Hash(String, String?).new
      @socket << "get"
      keys.each do |key|
        result[key] = nil
        @socket << " " << key
      end
      @socket << "\r\n"
      while (header = @socket.gets("\r\n", chomp: true)) && header != "END"
        headers = header.split
        key = headers[1]
        bytesize = headers[3].to_u32
        value = @socket.read_string(bytesize)
        @socket.read_string(2) # discard "\r\n"
        result[key] = value
      end
      result
    end

    def get_multi(*keys : String) : Hash(String, String?)
      get_multi(keys)
    end

    def delete(key : String) : String
      @socket << "delete #{key}\r\n"
      @socket.gets("\r\n", chomp: true).not_nil!
    end

    def incr(key : String, value : UInt64 = 1) : UInt64 | String
      @socket << "incr #{key} #{value}\r\n"
      ret = @socket.gets("\r\n", chomp: true).not_nil!
      ret.to_u64? || ret
    end

    def decr(key : String, value : UInt64 = 1) : UInt64 | String
      @socket << "decr #{key} #{value}\r\n"
      ret = @socket.gets("\r\n", chomp: true).not_nil!
      ret.to_u64? || ret
    end

    def touch(key : String, expire : Number) : String
      @socket << "touch #{key} #{expire}\r\n"
      @socket.gets("\r\n", chomp: true)
    end

    def flush_all : Bool
      @socket << "flush_all\r\n"
      @socket.gets("\r\n", chomp: true) == "OK"
    end
  end
end
