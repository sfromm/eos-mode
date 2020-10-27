;;; eos-mode.el --- edit Arista EOS configuration files -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Stephen Fromm

;; Author: Stephen Fromm
;; URL: https://github.com/sfromm/eos-mode
;; Package-Requires: ((emacs "24.1"))
;; Keywords: arista eos
;; Version: 0.3

;; This program is not part of GNU Emacs
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program; if not, write to the Free Software Foundation, Inc.,
;; 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
;;
;;; Commentary:
;; Based on ios-config-mode.el from https://github.com/nibrahim/IOS-config-mode
;; by Noufal Ibrahim.

;;; Code:

(require 'rx)

;;;###autoload
(defgroup eos-mode nil
  "EOS Mode"
  :group 'editing)

(defcustom eos-mode-hook nil
  "Hook called by \"eos-mode\"."
  :group 'eos-mode
  :type 'hook)


;; Constants

(defconst eos-mode-version "0.3" "Version of `eos-mode'.")

(defconst eos-section-regex
  (concat
   "^ *"
   (regexp-opt
    '("controller" "hardware tcam" "interface" "ip routing vrf"
      "ip access-list" "ip prefix-list" "ipv6 prefix-list"
      "line" "management api" "policy-map" "redundancy" "route-map" "router") t)))

(defconst eos-keywords-regex
  (regexp-opt
   '("aaa" "bgp" "description" "isis" "logging" "neighbor" "vlan" "vrf") 'words)
  "Regular expressions for EOS keywords.")

(defconst eos-commands-regex
  (concat
   "^ *"
   (regexp-opt
    '("ip community-list" "ip radius" "ip routing" "ip route"
      "ntp server" "radius-server" "snmp-server") t))
  "Regular expressions for EOS commands.")

(defconst eos-ipaddr-regex
  (rx
   (or
    (group (repeat 1 3 digit) "\."
           (repeat 1 3 digit) "\."
           (repeat 1 3 digit) "\."
           (repeat 1 3 digit)
           (optional "/" (one-or-more digit)))
    (group "::/" (one-or-more digit))))
  "RegExp for an IP address.")

(defconst eos-no-regex
  (regexp-opt '("no") 'words)
  "Regular expression for `no' commands.")

(defconst eos-shutdown-regex
  (regexp-opt '("shutdown") 'words)
  "Regular expression for `shutdown' command.")

(defvar eos-font-lock-keywords
  (list
   (list eos-section-regex 0 font-lock-function-name-face)
   (list eos-keywords-regex 0 font-lock-keyword-face)
   (list eos-commands-regex 0 font-lock-builtin-face)
   (list eos-ipaddr-regex 0 font-lock-string-face)
   (list eos-no-regex 0 font-lock-warning-face)
   (list eos-shutdown-regex 0 font-lock-warning-face)
   )
  "Font locking definitions for Arista eos mode.")


;; Mode setup

;; Imenu definitions.
(defvar eos-imenu-expression
  '(
    ("Vlans"                "^vlan *\\(.*\\)" 1)
    ("Interfaces"           "^[\t ]*interface *\\(.*\\)" 1)
    ("VRFs"                 "^ *vrf *\\(.*\\)" 1)
    ("Routing protocols"    "^router *\\(.*\\)" 1)
    ("TCAM profile feature" "^ *feature *\\(.*\\)" 1)
    ("Route-maps"           "^route-map *\\(.*\\)" 1)
    )
  "Imenu configuration for `eos-mode'.")

(defvar eos-mode-syntax-table
  (let ((syntax-table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" syntax-table)  ;; All _'s are part of words.
    (modify-syntax-entry ?- "w" syntax-table)  ;; All -'s are part of words.
    (modify-syntax-entry ?! "<" syntax-table)  ;; All !'s start comments.
    (modify-syntax-entry ?\n ">" syntax-table) ;; All newlines end comments.
    (modify-syntax-entry ?\r ">" syntax-table) ;; All linefeeds end comments.
    syntax-table)
  "Syntax table for Arista `eos-mode'.")

;;;###autoload
(define-derived-mode eos-mode text-mode "EOS"
  "Major mode for Arista EOS (TM) configuration files."
  :syntax-table eos-mode-syntax-table
  :group 'eos-mode
  (set (make-local-variable 'font-lock-defaults) '(eos-font-lock-keywords))
  (set (make-local-variable 'comment-start) "!")
  (set (make-local-variable 'comment-start-skip) "\\(\\(^\\|[^\\\\\n]\\)\\(\\\\\\\\\\)*\\)!+ *")
  (set (make-local-variable 'indent-tabs-mode) nil)
  (setq imenu-case-fold-search nil)
  (set (make-local-variable 'imenu-generic-expression) eos-imenu-expression)
  (imenu-add-to-menubar "Imenu"))

(defun eos-mode-version ()
  "Display version of `eos-mode'."
  (interactive)
  (message "eos-mode %s" eos-mode-version)
  eos-mode-version)

(provide 'eos-mode)

;;; eos-mode.el ends here
