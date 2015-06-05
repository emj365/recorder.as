package {

  import com.emj365.recorder_as.Recorder;
  import com.emj365.recorder_as.RecordingEvent;
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.system.Security;
  import flash.external.ExternalInterface;

  public class RecorderJSAdapter extends MovieClip {

    private var recorder:Recorder = new Recorder();

    public function RecorderJSAdapter() {
      Security.allowDomain('*');

      ExternalInterface.addCallback("enableDebug", enableDebug);

      ExternalInterface.addCallback("start", recorder.start);
      ExternalInterface.addCallback("stop", recorder.stop);
      ExternalInterface.addCallback("play", recorder.play);

      recorder.addEventListener(RecordingEvent.RECORDING_COMPLETE, recordingComplete);
      recorder.addEventListener(RecordingEvent.ENCODING_COMPLETE, encodingComplete);
      recorder.addEventListener(RecordingEvent.PLAYING_COMPLETE, playingComplete);
    }

    protected function enableDebug():void {
      ExternalInterface.marshallExceptions = true;
      recorder.addEventListener(RecordingEvent.LOG, log);
      recorder.addEventListener(RecordingEvent.ERROR, error);
      logInJS('[Recorder] debug enabled');
    }

    protected function recordingComplete(e:RecordingEvent):void {
      ExternalInterface.call('recordingComplete');
    }

    protected function encodingComplete(e:RecordingEvent):void {
      stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
        recorder.downloadMp3();
      });
      ExternalInterface.call('encodingComplete');
    }

    protected function playingComplete(e:RecordingEvent):void {
      ExternalInterface.call('playingComplete');
    }

    protected function log(e:RecordingEvent):void {
      logInJS('[Recorder Log] ', e.logMessage);
    }

    protected function error(e:RecordingEvent):void {
      logInJS('[Recorder Error] ', e.errorMessage);
    }

    protected function logInJS(...args):void {
      ExternalInterface.call('console.log', args.join(""));
    }

  }
}
