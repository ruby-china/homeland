module NotesHelper
  def render_node_topics_count(node)
    node.topics_count
  end
  
  def render_node_name(node)
    link_to(node.name, node_topics_path(node))
  end
end
