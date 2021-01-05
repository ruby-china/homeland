# ============ init Section, Node ================
%w[Fun Movie Music Apple Goolge Coding].each do |name|
  Node.create!(name: name, summary: "...")
end
