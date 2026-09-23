# nchat key bindings

The configuration uses no Alt key combinations.

nchat does not have readable names such as `KEY_CTRLF1`. The numeric values in `key.conf` are terminal codes for Ctrl modified function and navigation keys. They do not mean that you must press Alt.

## Navigation

| Action | Key |
| --- | --- |
| Move left | `Ctrl H` |
| Move right | `Ctrl L` |
| Move down | `Ctrl N` |
| Move up | `Ctrl P` |
| Next history page | `Ctrl F` |
| Previous history page | `Ctrl B` |
| First message | `Ctrl Home` |
| Latest message | `Ctrl End` |
| Next chat | `Tab` |
| Previous chat | `Shift Tab` |
| Next unread chat | `Ctrl Page Down` |
| Open chat picker | `Ctrl Shift F4` |
| Jump to pinned message | `Ctrl Shift F6` |
| Jump to quoted message | `Ctrl Shift F7` |

## Writing messages

| Action | Key |
| --- | --- |
| Send message | `Ctrl X` |
| Insert line break | `Enter` |
| Start of line | `Ctrl A` |
| End of line | `Ctrl E` |
| Previous word | `Ctrl F5` |
| Next word | `Ctrl Shift F3` |
| Delete to end of line | `Ctrl K` |
| Delete to start of line | `Ctrl U` |
| Delete previous word | `Ctrl F4` |
| Delete next word | `Ctrl Shift F8` |
| Clear input | `Ctrl C` |
| Copy | `Ctrl F6` |
| Cut | `Ctrl F7` |
| Paste | `Ctrl Shift F10` |
| External editor | `Ctrl F11` |
| Automatic compose | `Ctrl F2` |
| Spell check | `Ctrl Insert` |
| Insert tab | `Ctrl Delete` |
| Insert emoji | `Ctrl S` |
| Insert mention | `Ctrl Shift End` |

## Messages and chats

| Action | Key |
| --- | --- |
| Open attachment | `Ctrl V` |
| Open link | `Ctrl W` |
| Open message externally | `Ctrl Shift F9` |
| Save attachment | `Ctrl R` |
| Delete selected message | `Ctrl D` |
| Edit selected message | `Ctrl Z` |
| Forward selected message | `Ctrl Shift F2` |
| React to selected message | `Ctrl Shift F12` |
| Archive chat | `Ctrl F1` |
| Delete chat | `Ctrl F9` |
| Pin chat | `Ctrl Shift F11` |
| Find in chat | `Ctrl F12` |
| Find next | `Ctrl Shift F1` |
| Select contact | `Ctrl Shift Home` |
| Send file | `Ctrl T` |
| External call | `Ctrl F10` |

## Interface

| Action | Key |
| --- | --- |
| Cancel | `Ctrl [` |
| Quit | `Ctrl Q` |
| Toggle help | `Ctrl G` |
| Show other commands | `Ctrl O` |
| Toggle contact list | `Ctrl Page Up` |
| Toggle emoji display | `Ctrl Y` |
| Decrease list width | `Ctrl F8` |
| Increase list width | `Ctrl Shift F5` |

## Terminal code reference

The following patterns explain the numeric values in `key.conf`:

| Configuration pattern | Physical key |
| --- | --- |
| `\33\133\61\73\65...` | `Ctrl F1` through `Ctrl F4`, or Ctrl navigation |
| `\33\133...\73\65\176` | Ctrl modified function or navigation key |
| `\33\133...\73\66...` | Ctrl Shift modified function or navigation key |

These codes are required because the current nchat key parser supports named Ctrl letters, but does not support names for Ctrl modified function keys.
