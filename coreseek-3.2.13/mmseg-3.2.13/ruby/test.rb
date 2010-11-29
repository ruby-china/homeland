require "mmseg"

#t = Mmseg.new()
txt = "中文分词, 分词算法是一种计算机软件(a computer software)。这好像是废话！"
t = Mmseg.createSeg(".",txt)
while t.next()
	print txt[t.start...t.end]
	print '　'
end

50000.times {
#5.times {
	t.setText(txt)
	while t.next()
		#print txt[t.start...t.end]
		#print '　'
	end
}

t=nil