package {
  import Base64;
  import Mic;

  import fr.kikko.lab.ShineMP3Encoder;
  import com.adobe.audio.format.WAVWriter;

  import org.as3wavsound.WavSound;
  import org.as3wavsound.sazameki.core.AudioSetting;
  import org.as3wavsound.WavSoundChannel;

  import flash.events.*;
  import flash.utils.*;
  import flash.net.FileReference;
  import flash.display.MovieClip;

  import flash.system.Security;
  import flash.external.ExternalInterface;

  import flash.media.SoundChannel;

  public class YLRecorder extends MovieClip {

    private var mic:Mic;
    private var wavBytes:ByteArray;
    private var mp3Encoder:ShineMP3Encoder;

    public function YLRecorder() {
      //ExternalInterface.marshallExceptions = true;
      flash.system.Security.allowDomain('*')
      ExternalInterface.addCallback("startRecording", startRecording);
      ExternalInterface.addCallback("stopRecording", stopRecording);
      ExternalInterface.addCallback("previewRecording", previewRecording);
    }

    protected function startRecording():void {
      mic = new Mic();
      mic.addEventListener(ActivityEvent.ACTIVITY, micActivity);
      mic.addEventListener(Event.COMPLETE, recordingComplete);
      mic.addEventListener(DataEvent.DATA, function(event:DataEvent):void {
        log(event.data);
      });
      mic.start();
    }

    protected function stopRecording():void {
      mic.stop();
    }

    private function recordingComplete(e:Event):void {
      log('recording complete');

      var wAVWriter:WAVWriter = new WAVWriter();
      var sample:ByteArray = mic.buffer;

      log('sample legnth: ', sample.length);

      wavBytes = new ByteArray();
      wAVWriter.numOfChannels = 1;
      wAVWriter.sampleBitRate = 16;
      wAVWriter.samplingRate = 44100;
      wAVWriter.processSamples(wavBytes, sample, 44100, 1);
      log('wav legnth: ', wavBytes.length);

      wavBytes.position = 0;
      mp3Encoder = new ShineMP3Encoder(wavBytes, 32);
      mp3Encoder.addEventListener(Event.COMPLETE, mp3EncodeComplete);
      mp3Encoder.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
      mp3Encoder.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
      mp3Encoder.start();

    }

    private function previewRecording():void {
      var wavSound:WavSound;
      var soundChannel:WavSoundChannel;
      var audioSetting:AudioSetting;
      audioSetting = new AudioSetting(1, 44100, 16)
      wavSound = new WavSound(wavBytes, audioSetting);
      soundChannel = wavSound.play();
      soundChannel.addEventListener(Event.SOUND_COMPLETE, previewComplete);
    }

    private function previewComplete(event:Event):void {
      log("previewComplete");
      ExternalInterface.call("previewComplete");
    }

    private function micActivity(event:ActivityEvent):void {
      if (event.activating) {
        ExternalInterface.call("setCanRecording");
        log("Microphone can use");
      } else {
        log("Microphone can't use");
      }
    }

    private function mp3EncodeProgress(event:ProgressEvent):void {
      log(event.bytesLoaded + "%");
    }

    private function mp3EncodeError(event:ErrorEvent):void {
      log("[ERROR] : ", event.text);
    }

    private function mp3EncodeComplete(event:Event):void {
      log("mp3 length: ", mp3Encoder.getMP3Data().length);
      stage.addEventListener(MouseEvent.CLICK, function(event:Event):void {
        mp3Encoder.saveAs((new Date()).time.toString() + '.mp3');
      });
      ExternalInterface.call("uploadRecord", Base64.encodeByteArray(wavBytes));
    }

    private function log(...args):void {
      ExternalInterface.call("console.log", args.join(""));
    }

  }

}
