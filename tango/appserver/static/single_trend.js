require([
    'jquery',
    'underscore',
    'splunkjs/mvc',
    'splunkjs/mvc/simplesplunkview',
    'splunkjs/mvc/simplexml/element/single',
    'splunkjs/mvc/simplexml/ready!'
], function($, _, mvc, SimpleSplunkView, SingleElement) {
    // Custom view to annotate a single value element with a trend indicator
    var SingleValueTrendIndicator = SimpleSplunkView.extend({
        // Override fetch settings
        outputMode: 'json',
        returnCount: 2,
        // Default options
        options: {
            changeFieldType: 'text'
        },
        // Icon CSS classes
        icons: {
            increase: 'icon-triangle-up-small',
            decrease: 'icon-triangle-down-small'
        },
        // Template for trend indicator
        template: _.template(
                '<div class="single-trend <%- trendClass %>" title="Previous value: <%- prev %>">' +
                        '<i class="<%- icon %>"></i> ' +
                        '<%- diff %>' +
                        '</div>'
        ),
        displayMessage: function() {
            // Don't display messages
        },
        createView: function() {
            return true;
        },
        /**
         * Automatically extract the numerical value of the first and second result row and
         * create the trend value according to their difference
         *
         * @param data the search results
         * @returns {*} the model object to for the template
         */
        autoExtractTrend: function(data) {
            var icon = 'icon-minus', trendClass = 'nochange', diff = 'no change', field = this.settings.get('field');
            // Only show the change if we get 2 results from the search
            if (data.length < 2) {
                return null;
            }
            var cur = parseFloat(data[0][field]), prev = parseFloat(data[1][field]);
            // Calculate the change percentage between the first and second result
            var changePct = parseInt(((cur - prev) / prev) * 100);
            if (cur > prev) {
                trendClass = 'increase';
                icon = this.icons.increase;
                if (prev === 0) {
                    trendClass += ' infinity';
                    diff = "+ ∞";
                } else {
                    diff = ['+', String(changePct), '%'].join('');
                }
            } else if (cur < prev) {
                trendClass = 'decrease';
                icon = this.icons.decrease;
                diff = [String(changePct), '%'].join('');
            }
            return {
                icon: icon,
                trendClass: trendClass,
                diff: diff,
                prev: data[1][field]
            };
        },
        updateView: function(viz, data) {
            this.$el.empty();
            var model = null;
            if (this.settings.has('changeField')) {
                var icon = 'icon-minus', trendClass = 'nochange', diff = 'no change',
                    field = this.settings.get('field'), prev = "n/a";
                switch (this.settings.get('changeFieldType')) {
                    case 'percent':
                        var v = parseInt(data[0][this.settings.get('changeField')], 10);
                        if (v > 0) {
                            trendClass = 'increase';
                            icon = this.icons.increase;
                            diff = ['+', String(v), '%'].join('');
                        } else if (v < 0) {
                            trendClass = 'decrease';
                            icon = this.icons.decrease;
                            diff = [String(v), '%'].join('');
                        }
                        break;
                    default:
                        diff = data[0][this.settings.get('changeField')];
                        trendClass = data[0][this.settings.get('trendClassField')];
                        icon = this.icons[trendClass];
                }
                if (this.settings.has('prevField')) {
                    prev = data[0][this.settings.get('prevField')];
                }
                model = {
                    icon: icon,
                    trendClass: trendClass,
                    diff: diff,
                    prev: prev
                };
            } else {
                model = this.autoExtractTrend(data);
            }
            if (!model) {
                return;
            }
            // Render the HTML
            this.$el.html(this.template(model));
        }
    });
    // Find all single value elements created on the dashboard
    _(mvc.Components.toJSON()).chain().filter(function(el) {
        return el instanceof SingleElement;
    }).each(function(singleElement) {
                singleElement.getVisualization(function(single) {
                    // Inject a new element after the single value visualization
                    var $el = $('<div></div>').insertAfter(single.$el);
                    // Create a new change view to attach to the single value visualization
                    new SingleValueTrendIndicator(_.extend(single.settings.toJSON(), {
                        el: $el,
                        id: _.uniqueId('single')
                    }));
                });
            });
});
