module Chaining
  class App < Sinatra::Base
    configure do
      set(:bind, '0.0.0.0');
      set(:views, "#{Dir.pwd}/views");
      set(:public_folder, "#{Dir.pwd}/public");
    end

    before {
      puts %[BEFORE #{request.path} #{params}]
      if params.has_key?(:here); @vm = VM[params[:here]]; @vm.here = params[:here]; end;
      if params.has_key?(:h); @vm = VM[params[:h]]; @vm.here = params[:h]; end;
    }
    
    get('/') { puts %[INDEX #{@vm}]; erb :index }
    
    post('/save') {
      puts %[POST #{params} #{@vm}];
      content_type "application/json"
      here = params.delete(:here);
      file = params.delete(:file) || {};
      doc = params.delete(:doc);
      md5 = Digest::MD5.hexdigest(doc)
      @vm[:doc] = doc
      @vm[:md5] = md5
      
      #Chaining.ipfs.upload(request.host, { fn => %[#{@doc}\n#{ln.join("\n")}] })
      #@cid = FS.cid(fn)
      #puts "POST: #{@here}\n cid: #{@cid}\ndoc: #{@doc}\nparams: #{params}";
      return JSON.generate({ here: here, md5: md5 })
    }
    
    post('/upload') {
      content_type 'application/json';
      ii = ""
      puts %[UPLOAD #{params[:file][:filename]} #{params[:file][:type]}]
      ft = params[:file][:type]
      fn = params[:file][:filename]
      na = fn.gsub('public/', '').gsub(/\..+$/,'').gsub('-',' - ').gsub('_', ' ')
      ff = params[:file][:tempfile].read
      md5 = Digest::MD5.hexdigest(fn + ff)
      ext = fn.split(".")[-1]
      @h = { md5: md5 }
      if !File.exist?("public/#{md5}")
        File.open("public/#{md5}", 'w') { |f| f.write(ff.to_s) }
      end
      if /image/.match(ft)
        ii = "!"
        @h[:id] = md5
        @h[:obj] = %[img]
        @h[:upload] = %[<details closed><summary>#{na}</summary><img src='/#{md5}'></details>]
      elsif ft == "text/plain"
        @h[:id] = @vm.vm.txts.length
        @h[:obj] = %[txt(#{@h[:id]})]
        @vm.vm.txt @h[:id], md5
      elsif ft == "text/csv"
        @h[:id] = @vm.vm.csvs.length
        @h[:obj] = %[csv(#{@h[:id]})]
        @vm.vm.csv @h[:id], md5
      elsif ft == "image/pdf"
        
      end
      @h[:body] = "# #{na}\n* name: #{fn}\n* id: #{@h[:id]}\n* object: #{@h[:obj]}\n* type: #{ft}\n* md5: #{md5}\n\n#{ii}[#{fn}](/#{md5})\n"
      return JSON.generate(@h)
    }
    
    post('/script') {
      content_type "application/json"
      puts %[SCRIPT #{params} #{@vm}]
      @vm << params[:s]
      if "#{params[:title]}".length > 0
        t = params[:title]
      else
        t = "script"
      end
      return JSON.generate({ head: "# #{t}\n* now: #{Time.now.to_s}\n\n", body: @vm.to_s, chart: @vm.vm.document.to_jobs })
    }
    
    get('/manifest.json') { content_type('application/json'); erb :manifest, layout: false }
    
    get('/service-worker.js') { erb :sw, layout: false }
    
    get('/s') {
      if params[:md5] == @vm[:md5];
        erb(:save);
      else;
        redirect("/x/#{params[:here]}");
      end
    }
    
    get('/e') {
      if params[:md5] == @vm[:md5];
        erb(:index);
      else;
        redirect("/x/#{params[:here]}");
      end
    }
    
    get('/x/:here') { erb :here }
    
    get('/m/:c/u/:u') { content_type "application/json"; return JSON.generate(COIN.wallet(params[:c].to_sym, params[:u])); }
    get('/m/:c/rx/:i') { content_type "application/json"; return JSON.generate(COIN[params[:c].to_sym][params[:i]]); }
    get('/m/:c/tx') { content_type "application/json"; return JSON.generate(COIN[params[:c].to_sym].send(params[:from], params[:to], params[:amount], params[:memo]));  }
    get('/m/:c/x') { content_type "application/json"; return JSON.generate(COIN[params[:c].to_sym].mine(params[:u], params[:fingerprint])); }
    get('/m/i/:c') { erb :intake }
  end
  @@APP = Process.detach(fork { App.run! })
end
