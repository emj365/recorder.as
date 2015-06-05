package com.emj365.recorder_as {

  import Base64;
  import Mic;

  import fr.kikko.lab.ShineMP3Encoder;
  import com.adobe.audio.format.WAVWriter;

  import org.as3wavsound.WavSound;
  import org.as3wavsound.sazameki.core.AudioSetting;
  import org.as3wavsound.WavSoundChannel;

  import flash.events.*;
  import flash.utils.*;
  import flash.media.SoundChannel;

  public class Recorder extends EventDispatcher implements IRecorder {

    private var mic:Mic;
    private var wavBytes:ByteArray;
    private var mp3Encoder:ShineMP3Encoder;

    public function Recorder() {
    }

    public function start():void {
      log("start recording...");
      mic = new Mic();
      mic.addEventListener(ActivityEvent.ACTIVITY, micActivity);
      mic.addEventListener(Event.COMPLETE, recordingComplete);
      mic.addEventListener(DataEvent.DATA, function(event:DataEvent):void {
        log(event.data);
      });
      mic.start();
    }

    public function stop():void {
      mic.stop();
    }

    public function play():void {
      var audioSetting:AudioSetting;
      var wavSound:WavSound;
      var soundChannel:WavSoundChannel;
      audioSetting = new AudioSetting(1, 44100, 16)
      wavSound = new WavSound(wavBytes, audioSetting);
      soundChannel = wavSound.play();
      soundChannel.addEventListener(Event.SOUND_COMPLETE, playingComplete);
    }

    public function getMp3Base64():String {
      var wavBytesCopy:ByteArray = clone(wavBytes);
      return Base64.encodeByteArray(wavBytesCopy)
    }

    public function downloadMp3():void {
      mp3Encoder.saveAs((new Date()).time.toString() + '.mp3');
    }

    private function clone(source:Object):* {
      var myBA:ByteArray = new ByteArray();
      myBA.writeObject( source );
      myBA.position = 0;
      return( myBA.readObject() );
    }

    private function micActivity(event:ActivityEvent):void {
      if (event.activating) {
        log("Microphone can use");
      } else {
        error("Microphone can't use");
      }
    }

    private function recordingComplete(event:Event):void {
      var recordingCompleteEvent:RecordingEvent = new RecordingEvent ( RecordingEvent.RECORDING_COMPLETE );
      var sample:ByteArray = mic.buffer;
      log('sample legnth: ', sample.length);
      writeWav(sample);
      dispatchEvent(recordingCompleteEvent); // recording as WAV
      startMp3Encoding();
    }

    private function writeWav(sample:ByteArray):void {
      var wAVWriter:WAVWriter = new WAVWriter();
      wavBytes = new ByteArray();
      wAVWriter.numOfChannels = 1;
      wAVWriter.sampleBitRate = 16;
      wAVWriter.samplingRate = 44100;
      wAVWriter.processSamples(wavBytes, sample, 44100, 1);
      log('wav legnth: ', wavBytes.length);
    }

    private function startMp3Encoding():void {
      wavBytes.position = 0;
      mp3Encoder = new ShineMP3Encoder(wavBytes, 32);
      mp3Encoder.addEventListener(Event.COMPLETE, mp3EncodeComplete);
      mp3Encoder.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
      mp3Encoder.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
      mp3Encoder.start();
    }

    private function mp3EncodeComplete(event:Event):void {
      log("mp3 length: ", mp3Encoder.getMP3Data().length);
      var encodingCompleteEvent:RecordingEvent = new RecordingEvent ( RecordingEvent.ENCODING_COMPLETE );
      dispatchEvent(encodingCompleteEvent);
    }

    private function mp3EncodeProgress(event:ProgressEvent):void {
      log("mp3 progress: ", event.bytesLoaded, "%");
    }

    private function mp3EncodeError(event:ErrorEvent):void {
      error(event.text);
    }

    private function playingComplete():void {
      var playingCompleteEvent:RecordingEvent = new RecordingEvent ( RecordingEvent.PLAYING_COMPLETE );
      dispatchEvent(playingCompleteEvent);
    }

    private function log(...args):void {
      var logEvent:RecordingEvent = new RecordingEvent ( RecordingEvent.LOG );
      logEvent.logMessage = args.join("");
      dispatchEvent(logEvent);
    }

    private function error(...args):void {
      var errorEvent:RecordingEvent = new RecordingEvent ( RecordingEvent.ERROR );
      errorEvent.errorMessage = args.join("");
      dispatchEvent(errorEvent);
    }

  }

}
