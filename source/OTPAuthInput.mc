import Toybox.WatchUi;
import Toybox.Lang;

class OTPAuthInput extends WatchUi.BehaviorDelegate {
  private var otpView as OTPAuthView;

  function initialize(view as OTPAuthView) {
    BehaviorDelegate.initialize();
    otpView = view;
  }

  function onSelect() as Boolean {
    return onNextPage();
  }

  function onNextPage() as Boolean {
    if (WatchUi has :cancelAllAnimations) {
      WatchUi.cancelAllAnimations();
    }
    otpView.nextCode();
    return true;
  }

  function onPreviousPage() as Boolean {
    if (WatchUi has :cancelAllAnimations) {
      WatchUi.cancelAllAnimations();
    }
    otpView.prevCode();
    return true;
  }

  function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
    var dir = swipeEvent.getDirection();
    if (dir == WatchUi.SWIPE_UP || dir == WatchUi.SWIPE_LEFT) {
      return onNextPage();
    } else if (dir == WatchUi.SWIPE_DOWN || dir == WatchUi.SWIPE_RIGHT) {
      return onPreviousPage();
    }
    return false;
  }

  function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
    return onNextPage();
  }
}
