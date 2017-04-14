class Neuroprok::LearnController < NeuroprokController
  EVENTS = %w(push).freeze
  FILTER = %w(controllers models).freeze

  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :require_user, only: :create

  after_action :do_evaluation, only: :create, unless: proc {file_list.empty?}

  def create
    send(event) if EVENTS.include?(event)
    head 200
  end

  private

  def event
    @event ||= request.env['HTTP_X_GITHUB_EVENT']
  end

  def push
    FileUtils::mkdir_p("tmp/#{repo_name}") unless File.exists?("tmp/#{repo_name}")
    changes.each do |file|
      if File.extname(file) == '.rb'
        sauce = "https://raw.githubusercontent.com/#{repo_name}/#{commit}/#{file}"
        content = open(sauce).read
        File.open("tmp/#{repo_name}/#{File.basename(sauce)}", 'w') { |f| f.write(content) } unless content.empty?
      end
    end

    unless file_list.empty?
      save_to_csv
      `python fit.py #{repo_name}`
    end
  end

  def repo_name
    @repo_name ||= payload['repository']['full_name']
  end

  def commit
    @commit ||= payload['after']
  end

  def modified
    @modified ||= payload['commits'].last['modified']
  end

  def added
    @added ||= payload['commits'].last['added']
  end

  def changes
    @change = [] << added, modified
    @changes = []

    FILTER.each do |filter|
      @changes << @change.flatten.select { |c| c[/#{filter}/] }
    end
    @changes.flatten!
  end

  def file_list
    @file_list = Dir.glob("tmp/#{repo_name}/**/*.{rb}")
  end

  def payload
    JSON.parse(params[:payload])
  end

  def save_to_csv
    unless file_list.empty?
      file_list.shuffle.each do |file|
        parser = Corser::Parser::Ruby.new(file)
        2.times do |i|
          parser.save_to_csv(i, "size_of_all_keywords", "comments_size", "function_count", "single_quotes_size", "double_quotes_size", "tmp/#{repo_name}/dataset_#{i}.csv")
        end
      end
    end
  end

  def do_evaluation
    result = `python eval.py #{repo_name}`.split("\n").each { |c| p c }
    result[0] = result[0].to_f * 100
    result[1] = Hash[file_list.zip(result[1][1...-1].split(', '))]

    repo = Repo.find_by(name: repo_name)
    neuro = repo.neuro || repo.build_neuro

    neuro.update(accuracy:   result[0],
                 prediction: result[1])

    neuro.save
    clear_dir
  end

  def clear_dir
    zeroes_dataset = "tmp/#{repo_name}/dataset_0.csv"

    Dir.glob(file_list).each { |file| File.delete(file) }
    FileUtils.rm(zeroes_dataset) if File.exists?(zeroes_dataset)
  end
end
