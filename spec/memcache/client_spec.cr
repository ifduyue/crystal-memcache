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

  it "sets empty string and then gets" do
    client = Memcache::Client.new
    client.flush_all
    client.get("empty").should eq(nil)
    client.set("empty", "").should eq("STORED")
    client.get("empty").should eq("")
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

  it "gets multiple keys" do
    client = Memcache::Client.new
    client.flush_all
    client.set("1", "1")
    client.set("3", "3")
    client.set("6", "6")
    client.get_multi("0", "1", "2", "3", "4", "5").should eq({
      "0" => nil,
      "1" => "1",
      "2" => nil,
      "3" => "3",
      "4" => nil,
      "5" => nil,
    })
    client.get_multi(["0", "1", "2", "3", "4", "5"]).should eq({
      "0" => nil,
      "1" => "1",
      "2" => nil,
      "3" => "3",
      "4" => nil,
      "5" => nil,
    })
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

  it "gats key" do
    client = Memcache::Client.new
    client.flush_all
    client.set("gat", "1")
    client.gat(2, "gat").should eq("1")
    sleep(2)
    client.gat(2, "gat").should eq(nil)
  end

  it "gats multiple keys" do
    client = Memcache::Client.new
    client.flush_all
    client.set("1", "1")
    client.set("3", "3")
    client.set("6", "6")
    client.gat_multi(2, "0", "1", "2", "3", "4", "5").should eq({
      "0" => nil,
      "1" => "1",
      "2" => nil,
      "3" => "3",
      "4" => nil,
      "5" => nil,
    })
    client.gat_multi(2, ["0", "1", "2", "3", "4", "5"]).should eq({
      "0" => nil,
      "1" => "1",
      "2" => nil,
      "3" => "3",
      "4" => nil,
      "5" => nil,
    })
    sleep(2)
    client.gat_multi(2, "0", "1", "2", "3", "4", "5").should eq({
      "0" => nil,
      "1" => nil,
      "2" => nil,
      "3" => nil,
      "4" => nil,
      "5" => nil,
    })
    client.gat_multi(2, ["0", "1", "2", "3", "4", "5"]).should eq({
      "0" => nil,
      "1" => nil,
      "2" => nil,
      "3" => nil,
      "4" => nil,
      "5" => nil,
    })
  end
end
