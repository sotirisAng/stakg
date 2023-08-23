class RecordsController < ApplicationController
  def show
    @record = Record.find(params[:id])
    @trajectory = @record.recording_event.recording_position.trajectory
    @flight = Flight.find_by(trajectory_id: @trajectory.id)
    @attachment = @flight.flight_file.files.all.find { |ff| ff.filename == @record.name }

    response.headers.delete 'X-Frame-Options'

    send_data @attachment.download, filename: @attachment.filename.to_s, type: @attachment.content_type, disposition: 'inline'

    # if @attachment
    #   redirect_to rails_blob_path(@attachment, disposition: "inline")
    # else
    #   render plain: 'No image attached'
    # end



    # send_file @record.file_path, type: 'image/jpg', x_sendfile: true

  end
end