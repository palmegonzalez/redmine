require 'mailer'

class RequesterMailer < Mailer
  #layout 'requester_mailer'

  def mail(headers)
    plain_text_mail = headers.delete(:plain_text)

    @origin_to = headers[:to]
    @origin_cc = headers[:cc]
    super(headers) do |format|
      if plain_text_mail
        format.text
      else
        format.html
      end
    end
  end

  def requester_issue_add(issue, requester_email)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id
    message_id issue
    references issue
    @issue = issue
    mail :to => requester_email.value,
         :cc => '',
         :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
  end

  def requester_issue_edit(issue, requester_email)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id
    message_id issue
    references issue
    @issue = issue

    @journal = issue.journals.last

    mail :to => requester_email.value,
         :cc => '',
         :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
  end

  def requester_issue_finish(issue, requester_email)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id
    message_id issue
    references issue
    @issue = issue

    @journal = issue.journals.last

    mail :to => requester_email.value,
         :cc => '',
         :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
  end
end