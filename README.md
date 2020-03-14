# egg-timer.el

[![MELPA](https://melpa.org/packages/egg-timer-badge.svg)](https://melpa.org/#/egg-timer)
Use Emacs to set timers.

![schedule an alarm using Emacs][1]
![use the system's notification system to display the alarm][2]

## Installation

`egg-timer` is available on [MELPA](https://github.com/melpa/melpa). To install
you may need to run:

- `M-x` `package-refresh-contents`
- `M-x` `package-install` `egg-timer`

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

## Alternatives to egg-timer.el

[Many timer packages][melpa-timers] exist, so what's different about
`egg-timer`? Many of the timers on MELPA are [pomodoro
timers][wtf-pomodoro]. `egg-timer` is not exclusively a pomodoro timer --
although you could use `egg-timer-do-schedule` to create one if you'd
like.

`egg-timer` prompts users using Emacs's built-in `completing-read` function;
this integrates with [ivy][wtf-ivy] or other completion libraries that users may
prefer. `egg-timer` also notifies users with `notifications-notify`, which
integrates with the FreeDesktop notification protocol, notifying users at the
operating system level.

Enjoy responsibly.

[1]: ./screenshots/emacs-screenshot.png
[2]: ./screenshots/alert-screenshot.png
[3]: https://github.com/melpa/melpa
[melpa-timers]: https://melpa.org/#/?q=timer
[wtf-pomodoro]: https://en.wikipedia.org/wiki/Pomodoro_Technique
[wtf-ivy]: https://github.com/abo-abo/swiper#ivy
