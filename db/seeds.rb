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

# ============ create elasticsearch index ================
Topic.__elasticsearch__.create_index!
User.__elasticsearch__.create_index!
Page.__elasticsearch__.create_index! if Setting.has_module?(:wiki)
