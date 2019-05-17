NPM = $(call which,NPM,npm)
$(foreach VAR,NPM,$(call make-lazy,$(VAR)))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	node_modules \

SF_DEPS_TARGETS := \
	$(SF_DEPS_TARGETS) \
	deps-npm \
	deps-npm-audit \

ifdef SF_ECLINT_FILES_IGNORE
SF_ECLINT_FILES_IGNORE := \
	$(SF_ECLINT_FILES_IGNORE) \
	-e "^package-lock.json$$" \

endif

# ------------------------------------------------------------------------------

.PHONY: deps-npm-unmet-peer
deps-npm-unmet-peer:
	diff -U0 \
		<(cat package.json.unmet-peer 2>/dev/null | \
			$(GREP) --only-matching -e "npm ERR! peer dep missing: [^,]\+, required by [^@]\+" || true) \
		<($(NPM) list --depth=0 2>&1 | \
			$(GREP) --only-matching -e "npm ERR! peer dep missing: [^,]\+, required by [^@]\+") || { \
			$(ECHO_ERR) "Found (new) unmet peer dependencies."; \
			$(ECHO_INFO) "If you want to ignore one or more, add to package.json.unmet-peer,"; \
			$(ECHO_INFO) "the lines above that start with '+npm ERR! peer dep missing:'."; \
			exit 1; \
		}

.PHONY: deps-npm
deps-npm:
	$(eval NPM_LOGS_DIR := $(shell $(NPM) config get cache)/_logs)
	$(NPM) install
	if [[ -x node_modules/babel-preset-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/babel-preset-firecloud/npm-install-peer-dependencies; \
	fi
	if [[ -x node_modules/eslint-config-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/eslint-config-firecloud/npm-install-peer-dependencies; \
	fi
ifeq ($(CI),true)
	$(GIT) diff --exit-code package.json || { \
		$(ECHO_ERR) "package.json has changed."; \
		$(ECHO_ERR) "Run 'make deps-npm' locally, commit and push the changes before another CI run."; \
		exit 1; \
	}
endif
	$(NPM) prune
	$(GIT) ls-files --error-unmatch "package-lock.json" || { \
		$(CAT) package.json | \
			$(JQ)  ".dependencies + .devDependencies" | \
			$(JQ) "to_entries" | \
			$(JQ) ".[] | select(.value | contains(\"git\"))" | \
			$(JQ) -r ".key" | \
			$(XARGS) -L1 -I{} $(RM) node_modules/{}; \
		$(NPM) update --no-save --development; \
	}
	$(NPM) list --depth=0 || $(MAKE) deps-npm-unmet-peer


.PHONY: deps-npm-prod
deps-npm-prod:
	$(NPM) install --production
	$(NPM) prune --production
	$(GIT) ls-files --error-unmatch "package-lock.json" || { \
		$(CAT) package.json | \
			$(JQ)  ".dependencies" | \
			$(JQ) "to_entries" | \
			$(JQ) ".[] | select(.value | contains(\"git\"))" | \
			$(JQ) -r ".key" | \
			$(XARGS) -L1 -I{} $(RM) node_modules/{}; \
		$(NPM) update --no-save --production; \
	}
	$(NPM) list --depth=0 || $(MAKE) deps-npm-unmet-peer


# the audit can be ignored by adding to the Makefile:
# SF_DEPS_TARGETS := $(filter-out deps-npm-audit,$(SF_DEPS_TARGETS))

.PHONY: deps-npm-audit
deps-npm-audit:
	$(ECHO_DO) "Auditing package.json..."
	$(GIT) ls-files --error-unmatch "package-lock.json" || {
		$(RM) package-lock.json
		$(NPM) install --package-lock-only
	}
	$(NPM) audit || { \
		$(NPM) audit fix; \
		$(GIT) ls-files --error-unmatch "package-lock.json" || $(RM) package-lock.json; \
		exit 1; \
	}
	$(GIT) ls-files --error-unmatch "package-lock.json" || $(RM) package-lock.json
	$(ECHO_DONE)
