import {
  ChangeDetectionStrategy,
  Component,
} from '@angular/core';
import { I18nService } from 'core-app/core/i18n/i18n.service';

@Component({
  templateUrl: './kitten-page.component.html',
  styleUrls: ['./kitten-page.component.sass'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class KittenPageComponent{

  text = {
    kittens: this.I18n.t('js.roadmap_plugin_name'),
  };

  kittenName = 'FooBar';

  constructor(private I18n:I18nService) {
  }
}
