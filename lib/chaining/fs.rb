
module FS
  @@FS = PStore.new("db/fs.pstore")
  def self.upload d, h={}
    ipfs = IPFS::Connection.new
    folder = IPFS::Upload.folder(d) do |f|
      h.each_pair { |k,v| f.add_file(k) { |fd| fd.write v } }
    end
    ipfs.add folder do |node|
      @@FS.transaction { |db| db[node.name] = node.hash }
    end
  end
  
  def self.keys
    @@FS.transaction { |db| db.keys }
  end

  def self.each_pair &b
    @@FS.transaction { |db| db.keys.each { |e| b.call(e, db[e]) } }
  end

  def self.cid k
    @@FS.transaction { |db| db[k] }
  end
  
  def self.[] k
    @@FS.transaction { |db| @k = db[k] }
    ipfs = IPFS::Connection.new
    ipfs.cat(@k)
  end
end
module Chaining
  def self.ipfs
    FS
  end
end
