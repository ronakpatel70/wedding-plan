class DeleteSections < ActiveRecord::Migration
  def change
    rename_table :chapters, :articles
    add_column :articles, :content, :text
    rename_column :articles, :handbook, :page

    Article.all.each do |article|
      sections = Section.where(chapter_id: article.id)
      article.content = sections.map { |sec| "## #{sec.title}\n\n#{sec.content}" }.join("\n\n")
      article.save!
    end

    drop_table :sections
  end
end
