    $name_to_id = @{
        "бронзовый" = "bronze"
        "серебряный" = "silver"
        "2 сезонный" = "bp_season_2"
        "1 сезонный" = "bp_season_1"
        "4 сезонный" = "bp_season_4"
        "5 сезонный" = "bp_season_5"
        "3 сезонный" = "bp_season_3"
        "6 ЭТАП" = "bp_season_6"
        "7 ЭТАП" = "bp_season_7"
        "8 ЭТАП" = "bp_season_8"
        "9 ЭТАП" = "bp_season_9"
        "10 ЭТАП" = "bp_season_10"
        "золотой" = "gold"
        "andyfy" = "andyfy"
        "fresh" = "fresh"
        "победа" = "victory"
        "данилыч 2.0" = "danilich"
        "русский мишка" = "russian_bear"
        "disszari" = "disszari"
        "bosow" = "bosow"
        "донни" = "donny"
        "sodyan" = "sodyan"
        "бандиты" = "bands"
        "фракции" = "factions"
        "бригада" = "brigada"
        "мощный" = "powerful"
        "модный" = "fashionable"
        "мажор" = "major"
        "мажорный" = "major"
        "рокеры" = "rock"
        "рэперы" = "rap"
        "forsage" = "forsage"
        "механик" = "mechanic"
        "блатной" = "blatnoi"
        "люкс" = "lux"
        "mercedes" = "mercedes"
        "bmw" = "bmw"
        "monte carlo" = "monte_carlo"
        "байкер" = "biker"
        "русский" = "russian"
        "безумный 2.0" = "crazy"
        "ламба" = "lamba"
        "понтовый" = "pontovy"
        "бриллиантовый" = "diamond"
        "брилиантовый" = "diamond"
        "армейский" = "army"
        "императорский" = "imperial"
        "элитный 2.0" = "elite"
        "перевозчик" = "carrier"
        "четкий" = "4etkii"
        "кошерный" = "kosher"
        "опасный" = "dangerous"
        "немецкий 3.0" = "german"
        "мужской" = "male"
        "морской" = "sea"
        "отечественный" = "patriot"
        "японский" = "japan"
        "хэллоуин" = "halloween"
        "авиационный" = "air"
        "итальянский" = "italy"
        "экологический" = "eco"
        "героический" = "hero"
        "москва" = "moscow"
        "дубай" = "dubai"
        "англия" = "uk"
        "небо" = "sky"
        "америка" = "usa"
        "война" = "war"
        "европа" = "euro"
        "ангелы" = "angel"
        "демоны" = "demon"
        "земля" = "earth"
        "мир" = "peace"
        "франция" = "france"
        "стремительный" = "rapid"
        "роллс" = "rolls"
        "спортивный" = "sport"
        "гоночный" = "racing"
        "уличный" = "street"
        "роскошный" = "sumptuous"
        "титановый" = "titan"
        "платиновый" = "platinum"

        "базовый"         = "tuning_1"
        "счастливчик"     = "tuning_2"
        "фартовый"        = "tuning_3"
        "скоростной удар" = "tuning_4"
        "максимальный"    = "tuning_5"
        "стильный"        = "vinyl_1"
        "королевский"     = "vinyl_2"
        "легендарный"     = "vinyl_3"

    }

    Write-Host $PSScriptRoot

    $files = Get-ChildItem -literalpath  $PSScriptRoot -Filter *.png -Recurse

    foreach ($f in $files){
        # $outfile = $f.FullName + "out" 

        # Rename-Item -Path $f.FullName -NewName { $_.Name -replace $_.Basename, $name_to_id[ $_.Basename.ToLower().replace(' кейс', '').replace('кейс ', '') ] }

        # Write-Host $f.Basename.ToLower().replace(' кейс', '').replace('кейс ', '')

        $repl = $name_to_id[ $f.Basename.ToLower().replace(' кейс', '').replace('кейс ', '') ]
        if ($repl) {
            $kek = $f.Name -replace $f.Basename, $repl
            Rename-Item -literalpath $f.FullName -NewName $kek
        } 
        else {
            Rename-Item -literalpath $f.FullName -NewName $f.Name.ToLower()
        }

        # Write-Host "$applyProfileResult. Profile applied"
    }

    # Get-ChildItem $PSScriptRoot | Write-Host "$applyProfileResult. Profile applied"

    # if ($profile) {
    #     $applied = $profileApi.ApplyProfile($profile.ProfileID, [ref]$applyProfileResult)
    #     if ($applied) {
    #         Write-Host "$applyProfileResult. Profile applied"
    #     } else {
    #         Write-Host "$applyProfileResult. Profile not applied." 
    #     }
    # }

    Write-Host "end"