class <%= class_name -%> < ActiveRecord::Base
  set_table_name :<%= table_name %>
  set_primary_key :<%= primary_key %>
  
  # Relationships
  <%- relations[:has_some].each do |class_name, foreign_key| 
  -%>  has_many   <%= class_name.inspect %>, :foreign_key => <%= foreign_key.inspect %>
  <%- end -%>
  <%- relations[:belongs_to].each do |class_name, foreign_key| 
  -%>  belongs_to <%= class_name.inspect %>, :foreign_key => <%= foreign_key.inspect %>
  <%- end -%>

  # Constraints
  validates_uniqueness_of <%= constraints[:unique].map {|cols| cols.first.downcase.to_sym.inspect}.join(', ') %>
  <%- constraints[:multi_column_unique].each do |cols| 
  -%>  #validates_uniqueness_of_multiple_column_constraint :<%= cols.inspect %>
  <%- end -%>
  validates_presence_of <%= constraints[:non_nullable].map {|col| col.downcase.to_sym.inspect}.join(', ') %>
  <%- constraints[:custom].each do |name, sql_rule| 
  -%>  validate <%= "validate_#{name}".to_sym.inspect %>
  def <%= "validate_#{name}" %>
    # TODO: validate this SQL constraint "<%= sql_rule %>"
  end
  <%- end %>
end
