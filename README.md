# alarm.el

Use Emacs and [ivy][1] to schedule alarms.

![schedule an alarm using Emacs][4]
![use the system's notification system to display the alarm][5]

## Dependencies
- `ivy.el`

## Installation

To use this package ensure that you have the `ivy` module available in your
Emacs. Consult the [installation instructions][2] for more information.

`alarm` will be available on [MELPA][3] soon. In the meantime, you can download
`alarm.el` and ensure that it's available on your `load-path` so that you can
call:

```elisp
(require 'alarm)
```

## Configuration

This module intentionally does not define any keybindings. If you'd like a
faster way to set alarms, consider using and adapting the following snippet:

```elisp
(require 'alarm)
(global-set-key (kbd "C-s-a") #'alarm-ivy-schedule)
```

If you'd like to customize the intervals that `alarm.el` uses, the variable
`alarm-intervals` should suffice. For example, if you'd like to support an alarm
for 3 hours:

```elisp
(setq alarm-intervals (add-to-list 'alarm-intervals '("3 hour" . 180)))
```

For more information:
- See the module documentation in `alarm.el`.

[1]: https://github.com/abo-abo/swiper#ivy
[2]: https://github.com/abo-abo/swiper#installation
[3]: https://github.com/melpa/melpa
[4]: ./screenshots/emacs-screenshot.png
[5]: ./screenshots/alert-screenshot.png
