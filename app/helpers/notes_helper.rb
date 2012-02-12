module NotesHelper
  def render_node_topics_count(node)
    node.topics_count
  end

  def render_node_name(name, id)
    link_to(name, node_topics_path(id))
  end
end
