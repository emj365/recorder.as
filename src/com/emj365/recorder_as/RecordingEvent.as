package com.emj365.recorder_as {

  import flash.events.Event;

  public final class RecordingEvent extends Event {

    public static const LOG:String   = "log";
    public static const ERROR:String = "error";

    public static const RECORDING:String = "recording";
    public static const ENCODING:String  = "encoding";
    public static const PLAYING:String   = "playing";

    public static const RECORDING_COMPLETE:String = "recordingComplete";
    public static const ENCODING_COMPLETE:String  = "encodingComplete";
    public static const PLAYING_COMPLETE:String   = "playingComplete";

    private var _logMessage:String;
    private var _errorMessage:String;

    private var _recordingSeconds:Number;
    private var _playingSeconds:Number;
    private var _encordingPercentage:Number;

    public function set logMessage(message:String):void {
      _logMessage = message;
    }

    public function get logMessage():String {
      return _logMessage;
    }

    public function set errorMessage(message:String):void {
      _errorMessage = message;
    }

    public function get errorMessage():String {
      return _errorMessage;
    }

    public function RecordingEvent(type:String) {
      super(type, false, false);
    }

  }

}
