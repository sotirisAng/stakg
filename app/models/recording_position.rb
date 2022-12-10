class RecordingPosition < RawPosition
  id_property :neo_id

  has_one :in, :recording_event, type: :occurs, model_class: :RecordingEvent
  has_one :in, :recording_segment, type: :comprises, model_class: :RecordingSegment

end
