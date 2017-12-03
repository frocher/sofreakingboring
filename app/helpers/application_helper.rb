require 'chronic_duration'

module ApplicationHelper

  def avatar_icon(user_email = '', size = nil)
    user = User.find_by(email: user_email)
    if user && user.avatar.present?
      size = 120 if size.nil? || size <= 0
      tag = size <= 100 ? :thumb : :medium
      if request.nil?
        user.avatar.url(tag)
      else
        URI.join(request.url, user.avatar.url(tag))
      end
    else
      gravatar_icon(user_email, size)
    end
  end

  def gravatar_icon(user_email = '', size = nil)
    size = 120 if size.nil? || size <= 0

    plain_url = 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
    ssl_url = 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
    gravatar_url = ENV.fetch("GRAVATAR_HTTPS", false) ? ssl_url : plain_url
    user_email.strip!
    sprintf gravatar_url, hash: Digest::MD5.hexdigest(user_email.downcase), size: size
  end

  def randomized_background_image
    images = ["/assets/intro-bug.jpg", "/assets/intro-mantis.jpg", "/assets/intro-town.jpg"]
    images[rand(images.size)]
  end

  def date_only(datetime)
    datetime.strftime("%b %d, %Y")
  end

  def to_days(minutes)
    to_day = 60 * 8
    (Float(minutes) / to_day).round(1)
  end

  def to_date(day)
    DateTime.strptime(day, "%Y%m%d")
  end

  def duration(minutes)
    if minutes == 0
      "0"
    elsif minutes < 0
      '-' + ChronicDuration.output(-minutes, format: :short)
    else
      ChronicDuration.output(minutes, format: :short)
    end
  end

 def body_data_page
    path = controller.controller_path.split('/')
    namespace = path.first if path.second

    [namespace, controller.controller_name, controller.action_name].compact.join(":")
  end

end
