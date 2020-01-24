require "spec"

describe Memcache::Client do
  it "sets and then gets" do
    client = Memcache::Client.new
    client.flush_all
    client.set("Hello", "World").should eq("STORED")
    client.set("Hello", "World").should eq("STORED")
    client.get("Hello").should eq("World")
    client.set("Hello", "World!").should eq("STORED")
    client.get("Hello").should eq("World!")
  end

  it "sets and then gets a large value" do
    client = Memcache::Client.new
    client.flush_all
    value = Random.new.random_bytes(32768)
    client.set("large", value).should eq("STORED")
    client.get("large").not_nil!.to_slice.should eq(value)
  end

  it "does not get non existing key" do
    client = Memcache::Client.new
    client.flush_all
    client.get("you_cannot_get_me").should eq(nil)
  end

  it "sets with expire" do
    client = Memcache::Client.new
    client.flush_all
    client.set("expires", "soon", 2)
    client.get("expires").should eq("soon")
    sleep(2)
    client.get("expires").should eq(nil)
  end

  it "deletes key" do
    client = Memcache::Client.new
    client.flush_all
    client.set("key", "value")
    client.get("key").should eq("value")
    client.delete("key").should eq("DELETED")
    client.get("key").should eq(nil)
    client.delete("key").should eq("NOT_FOUND")
  end

  it "appends key" do
    client = Memcache::Client.new
    client.flush_all
    client.append("append", "1").should eq("NOT_STORED")
    client.set("append", "1").should eq("STORED")
    client.get("append").should eq("1")
    client.append("append", "2").should eq("STORED")
    client.get("append").should eq("12")
    client.append("append", "3").should eq("STORED")
    client.get("append").should eq("123")
  end

  it "prepends key" do
    client = Memcache::Client.new
    client.flush_all
    client.prepend("prepend", "1").should eq("NOT_STORED")
    client.set("prepend", "1").should eq("STORED")
    client.get("prepend").should eq("1")
    client.prepend("prepend", "2").should eq("STORED")
    client.get("prepend").should eq("21")
    client.prepend("prepend", "3").should eq("STORED")
    client.get("prepend").should eq("321")
  end

  it "adds key" do
    client = Memcache::Client.new
    client.flush_all
    client.add("add", "1").should eq("STORED")
    client.get("add").should eq("1")
    client.add("add", "2").should eq("NOT_STORED")
    client.get("add").should eq("1")
  end
end
