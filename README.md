# egg-timer.el

Use Emacs to set timers.

![schedule an alarm using Emacs][1]
![use the system's notification system to display the alarm][2]

## Installation

`egg-timer` will be available on [MELPA][3] soon. In the meantime, you can
download `egg-timer.el` and ensure that it's available on your `load-path` so
that you can call:

```elisp
(require 'egg-timer)
```

## Configuration

This module intentionally does not define any keybindings. If you'd like to set
one yourself, consider using and adapting the following snippet:

```elisp
(require 'egg-timer)
(global-set-key (kbd "C-s-a") #'egg-timer-schedule)
```

If you'd like to customize the intervals that `egg-timer.el` uses, the variable
`egg-timer-intervals` should suffice. For example, if you'd like to support a
timer for 3 hours:

```elisp
(setq egg-timer-intervals (add-to-list 'egg-timer-intervals '("3 hour" . 180)))
```

If you'd like to create a keybinding to immediately schedule an alarm instead of
being prompted for a list of options, use `egg-timer-do-schedule`:

```elisp
(global-set-key (kbd "C-s-a") (lambda () (interactive) (egg-timer-do-schedule 2)))
```

For more information:
- See the module documentation in `egg-timer.el`.

[1]: ./screenshots/emacs-screenshot.png
[2]: ./screenshots/alert-screenshot.png
[3]: https://github.com/melpa/melpa
