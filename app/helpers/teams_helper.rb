module TeamsHelper
  def team_member_counts_tag(team)
    count_text = I18n.t("teams.team_users_count", count: team.team_users_count)

    content_tag(:i, nil, class: "fa fa-users") +
      content_tag(:span, count_text, class: "team-users-count")
  end
end
