class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def new
  end
	
  def create
    @document = Document.new(document_params)
    @document.save
    
    # Fill the TSVECTOR column in the database -> I really need to learn ActiveRecords AIP <_<
    sql1 = "SELECT id FROM documents WHERE id=(SELECT max(id) FROM documents)"
    id = ActiveRecord::Base.connection.execute(sql1).values
    
    idString = id[0].to_s;
    idString.delete! '["]'
    sql2 = "UPDATE documents SET texttsv= to_tsvector('" + @document.text + "') WHERE id='" + idString + "'"
	ActiveRecord::Base.connection.execute(sql2)
    
    redirect_to action: "index"
  end
 
  
  private
    def document_params
	  params.require(:document).permit(:text)
	end
	
end
