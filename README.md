# egg-timer.el

## Introduction to the fork

This is a fork of the excellent and original egg-timer.el because I really liked the simplicity of the interface here but I wanted to be able to free form enter text for choosing a timer's time as well as select from a list with completion, also I wanted to make it work on systems where I didn't have access to DBUS notifications (remote terminal machines, windows machines, etc) so I wanted to
make the notification system more customisable if I wanted too, and then I wanted the ability to list/modify the timers running... so I sort of took the original incredibly simple and beautiful code and mangled it with complexity.

But the users experience of it should remain very simple.

This version exposes four functions to the user:

* `egg-timer-schedule` lets you schedule a timer either from a completing read or entering any time string that looks right enough according to `timer-duration-words` so writing "3 seconds" or "3 hours" would give you a timer for "3 second" or "3 hour" because it trims off -s and things.
* `egg-timer-p` tells you if you have running timers
* `egg-timer-list` lists your running timers
* `egg-timer-cancel` lets you choose a timer to cancel

There is also a variable `egg-timer-notification-method` that lets you choose now notifications work, by default it uses `notifications-notify` but it can be set to `'buffer` to pop up  buffer showing when the timer completes or `'message` to just display a message.  If it is linked to a function then it will call that function and pass it the label of the timer to display, this can be either a lambda or a #'my-function 

Everything below here is the original documentation

---

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
