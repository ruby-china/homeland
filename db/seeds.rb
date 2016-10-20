# ============ init Section, Node ================
s1 = Section.create(name: 'Share')
Node.create(name: 'Fun', summary: '...', section_id: s1.id)
Node.create(name: 'Movie', summary: '...', section_id: s1.id)
Node.create(name: 'Music', summary: '...', section_id: s1.id)
s2 = Section.create(name: 'Geek')
Node.create(name: 'Apple', summary: '...', section_id: s2.id)
Node.create(name: 'Google', summary: '...', section_id: s2.id)
Node.create(name: 'Coding', summary: '...', section_id: s2.id)
Node.create(name: 'PlayStation / XBox', summary: '...', section_id: s2.id)

# ============ Init Site Node ================
SiteNode.create(name: "News", sort: 100)
SiteNode.create(name: "Blog", sort: 99)
SiteNode.create(name: "Other", sort: 94)
