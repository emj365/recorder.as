package com.emj365.recorder_as {

  import flash.events.EventDispatcher;

  public interface IRecorder {

    function start():void;
    function stop():void;
    function play():void;
    function getMp3Base64():String;
    function downloadMp3():void;

  }
}
