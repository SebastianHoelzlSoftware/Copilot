/**
 * topbar 1.0.0
 * https://buunguyen.github.io/topbar
 * MIT licensed
 *
 * Copyright (C) 2021 Buu Nguyen -- http://buunguyen.net
 */

(function(window, document) {
  "use strict";

  // https://gist.github.com/paulirish/1579671
  (function() {
    var lastTime = 0;
    var vendors = ["ms", "moz", "webkit", "o"];
    for (var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
      window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"];
      window.cancelAnimationFrame =
        window[vendors[x] + "CancelAnimationFrame"] ||
        window[vendors[x] + "CancelRequestAnimationFrame"];
    }

    if (!window.requestAnimationFrame)
      window.requestAnimationFrame = function(callback, element) {
        var currTime = new Date().getTime();
        var timeToCall = Math.max(0, 16 - (currTime - lastTime));
        var id = window.setTimeout(function() {
          callback(currTime + timeToCall);
        }, timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };

    if (!window.cancelAnimationFrame)
      window.cancelAnimationFrame = function(id) {
        clearTimeout(id);
      };
  })();

  var canvas, progress, topbar;

  var options = {
    autoRun: true,
    barThickness: 3,
    barColors: {
      "0": "rgba(26,  188, 156, .9)",
      ".25": "rgba(52,  152, 219, .9)",
      ".50": "rgba(241, 196, 15,  .9)",
      ".75": "rgba(230, 126, 34,  .9)",
      "1.0": "rgba(211, 84,  0,   .9)"
    },
    shadowBlur: 10,
    shadowColor: "rgba(0,   0,   0,   .6)",
    className: null
  };

  var repaint = function() {
    canvas.width = window.innerWidth;
    canvas.height = options.barThickness * 5; // need space for shadow

    var ctx = canvas.getContext("2d");
    ctx.shadowBlur = options.shadowBlur;
    ctx.shadowColor = options.shadowColor;

    var lineGradient = ctx.createLinearGradient(0, 0, canvas.width, 0);
    for (var stop in options.barColors)
      lineGradient.addColorStop(stop, options.barColors[stop]);
    ctx.lineWidth = options.barThickness;
    ctx.beginPath();
    ctx.moveTo(0, options.barThickness / 2);
    ctx.lineTo(
      Math.ceil(canvas.width * progress),
      options.barThickness / 2
    );
    ctx.strokeStyle = lineGradient;
    ctx.stroke();

    requestAnimationFrame(repaint);
  };

  var createCanvas = function() {
    canvas = document.createElement("canvas");
    var style = canvas.style;
    style.position = "fixed";
    style.top = "0";
    style.left = "0";
    style.right = "0";
    style.zIndex = "9999";
    if (options.className) canvas.classList.add(options.className);
    document.body.appendChild(canvas);
  };

  var hide = function() {
    canvas.style.opacity = 0;
    setTimeout(function() {
      canvas.style.display = "none";
    }, 500);
  };

  var show = function() {
    canvas.style.opacity = 1;
    canvas.style.display = "block";
  };

  topbar = {
    config: function(opts) {
      for (var key in opts) {
        if (options.hasOwnProperty(key)) {
          options[key] = opts[key];
        }
      }
    },

    show: function() {
      if (!canvas) {
        createCanvas();
        repaint();
      }
      show();
    },

    hide: function() {
      if (canvas) {
        hide();
      }
    },

    progress: function(to) {
      if (typeof to === "undefined") return progress;
      if (to > 1) to = 1;
      progress = to;
    }
  };

  if (options.autoRun) {
    var timeout = null;
    var latency = 200;
    var step = (1 / 100) * 2;

    var tick = function() {
      progress += step;
      if (progress > 1) {
        progress = 1;
        hide();
        timeout = null;
        return;
      }
      timeout = setTimeout(tick, latency);
    };

    topbar.show = function() {
      if (!canvas) {
        createCanvas();
        repaint();
      }
      show();
      progress = 0;
      if (timeout) clearTimeout(timeout);
      timeout = setTimeout(tick, latency);
    };
  }

  if (typeof module === "object" && typeof module.exports === "object") {
    module.exports = topbar;
  } else if (typeof define === "function" && define.amd) {
    define(function() {
      return topbar;
    });
  } else {
    this.topbar = topbar;
  }
}.call(this, window, document));
