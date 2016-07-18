module NotesHelper
  def render_node_name(name, id)
    link_to(name, main_app.node_topics_path(id), class: 'node')
  end

  def note_title_tag(note, opts = {})
    opts[:limit] ||= 50
    return '' if note.blank?
    return '' if note.title.blank?
    truncate(note.title.delete('#'), length: opts[:limit])
  end
end
