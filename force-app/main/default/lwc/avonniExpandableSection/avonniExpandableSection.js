/**
 * BSD 3-Clause License
 *
 * Copyright (c) 2021, Avonni Labs, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * - Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import { LightningElement, api } from 'lwc';
import { classSet } from 'c/utils';
import { normalizeBoolean, normalizeString } from 'c/utilsPrivate';

const VARIANTS = {
    default: 'shaded',
    valid: ['base', 'shaded']
};

/**
 * @class
 * @descriptor avonni-expandable-section
 * @storyId example-expandable-section--base
 * @public
 */
export default class AvonniExpandableSection extends LightningElement {
    /**
     * The title can include text, and is displayed in the header.
     *
     * @type {string}
     * @public
     */
    @api title;

    _closed = false;
    _collapsible = false;
    _variant = VARIANTS.default;

    /*
     * ------------------------------------------------------------
     *  PUBLIC PROPERTIES
     * -------------------------------------------------------------
     */

    /**
     * If present, close the section.
     *
     * @type {boolean}
     * @public
     * @default false
     */
    @api
    get closed() {
        return this._closed;
    }

    set closed(value) {
        this._closed = normalizeBoolean(value);
    }

    /**
     * If present, the section is collapsible.
     *
     * @type {boolean}
     * @public
     * @default false
     */
    @api
    get collapsible() {
        return this._collapsible;
    }

    set collapsible(value) {
        this._collapsible = normalizeBoolean(value);
    }

    /**
     * Variant of the section. Valid values include base and shaded.
     *
     * @type {string}
     * @public
     * @default base
     */
    @api
    get variant() {
        return this._variant;
    }

    set variant(value) {
        this._variant = normalizeString(value, {
            validValues: VARIANTS.valid,
            fallbackValues: VARIANTS.default
        });
    }

    /*
     * ------------------------------------------------------------
     *  PRIVATE PROPERTIES
     * -------------------------------------------------------------
     */

    /**
     * Computed list of the section classes.
     *
     * @type {string}
     * @default slds-section
     */
    get sectionClass() {
        return classSet('slds-section')
            .add({
                'slds-is-open': !this.collapsible || !this.closed
            })
            .toString();
    }

    /**
     * Computed list of the header classes.
     *
     * @type {string}
     * @default slds-section__title
     */
    get headerClass() {
        return classSet('slds-section__title')
            .add({
                'slds-theme_shade':
                    !this.collapsible && this.variant === 'shaded',
                'avonni-expandable-section__header_collapsible':
                    this.collapsible
            })
            .add(`avonni-expandable-section__header_${this._variant}`)
            .toString();
    }

    /**
     * Computed list of the title classes, when the section is collapsible and the title is a button.
     *
     * @type {string}
     * @default slds-button slds-section__title-action
     */
    get titleButtonClass() {
        return classSet('slds-button slds-section__title-action')
            .add({
                'slds-theme_default avonni-expandable-section__title-button_base':
                    this.variant === 'base',
                'avonni-expandable-section__title-button_shaded':
                    this.variant === 'shaded'
            })
            .toString();
    }

    /**
     * If true, the header is visible.
     *
     * @type {boolean}
     * @default false
     */
    get showHeader() {
        return this.title || this.collapsible;
    }

    /*
     * ------------------------------------------------------------
     *  PRIVATE METHODS
     * -------------------------------------------------------------
     */

    /**
     * Section change status toggle.
     */
    toggleSection() {
        this._closed = !this._closed;

        /**
         * The event fired when the expandable section is closed or opened.
         *
         * @event
         * @name toggle
         * @param {boolean} closed
         * @public
         */
        this.dispatchEvent(
            new CustomEvent('toggle', {
                detail: {
                    closed: this._closed
                }
            })
        );
    }
}