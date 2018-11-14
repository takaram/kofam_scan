((ruby-mode . ((eval . (setq-local flycheck-command-wrapper-function
                                   (lambda (command)
                                     (append '("bundle" "exec") command)))))))
