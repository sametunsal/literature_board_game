using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public enum MasteryLevel
{
    Novice = 0,
    Cirak  = 1,
    Kalfa  = 2,
    Usta   = 3
}

[Serializable]
public class CategoryLevelEntry
{
    public string category;
    public int level;

    public CategoryLevelEntry() { }

    public CategoryLevelEntry(string category, int level)
    {
        this.category = category;
        this.level = level;
    }
}

[Serializable]
public class DifficultyProgressEntry
{
    public string difficulty;
    public int count;

    public DifficultyProgressEntry() { }

    public DifficultyProgressEntry(string difficulty, int count)
    {
        this.difficulty = difficulty;
        this.count = count;
    }
}

[Serializable]
public class CategoryProgressEntry
{
    public string category;
    public List<DifficultyProgressEntry> difficultyProgress = new List<DifficultyProgressEntry>();

    public CategoryProgressEntry() { }

    public CategoryProgressEntry(string category, List<DifficultyProgressEntry> difficultyProgress)
    {
        this.category = category;
        this.difficultyProgress = difficultyProgress;
    }
}

[System.Serializable]
public class PlayerData
{
    public string id;
    public string name;
    public Color color;
    public int iconIndex;
    public int position;
    public bool inJail;
    public int turnsToSkip;
    public int stars;
    public List<string> collectedQuotes = new List<string>();
    public List<CategoryLevelEntry> categoryLevels = new List<CategoryLevelEntry>();
    public List<CategoryProgressEntry> categoryProgress = new List<CategoryProgressEntry>();
    public string mainTitle = "\u00c7aylak";

    public int GetLevel(string category)
    {
        var entry = categoryLevels.FirstOrDefault(e => e.category == category);
        return entry != null ? entry.level : 0;
    }

    public MasteryLevel GetMasteryLevel(string category)
    {
        int level = Mathf.Clamp(GetLevel(category), 0, 3);
        return (MasteryLevel)level;
    }

    public void SetLevel(string category, int level)
    {
        var entry = categoryLevels.FirstOrDefault(e => e.category == category);
        if (entry != null)
            entry.level = level;
        else
            categoryLevels.Add(new CategoryLevelEntry(category, level));
    }

    public int GetCorrectAnswerCount(string category, string difficulty)
    {
        var catEntry = categoryProgress.FirstOrDefault(e => e.category == category);
        if (catEntry == null) return 0;
        var diffEntry = catEntry.difficultyProgress.FirstOrDefault(e => e.difficulty == difficulty);
        return diffEntry != null ? diffEntry.count : 0;
    }

    public int RecordCorrectAnswer(string category, string difficulty)
    {
        var catEntry = categoryProgress.FirstOrDefault(e => e.category == category);
        if (catEntry == null)
        {
            catEntry = new CategoryProgressEntry(category, new List<DifficultyProgressEntry>());
            categoryProgress.Add(catEntry);
        }
        var diffEntry = catEntry.difficultyProgress.FirstOrDefault(e => e.difficulty == difficulty);
        if (diffEntry != null)
        {
            diffEntry.count++;
        }
        else
        {
            diffEntry = new DifficultyProgressEntry(difficulty, 1);
            catEntry.difficultyProgress.Add(diffEntry);
        }
        return diffEntry.count;
    }

    public bool CanPromoteToCirak(string category)
    {
        if (GetMasteryLevel(category) != MasteryLevel.Novice) return false;
        return GetCorrectAnswerCount(category, "easy") >= 3;
    }

    public bool CanPromoteToKalfa(string category)
    {
        if (GetMasteryLevel(category) != MasteryLevel.Cirak) return false;
        return GetCorrectAnswerCount(category, "medium") >= 3;
    }

    public bool CanPromoteToUsta(string category)
    {
        if (GetMasteryLevel(category) != MasteryLevel.Kalfa) return false;
        return GetCorrectAnswerCount(category, "hard") >= 3;
    }

    public MasteryLevel PromoteInCategory(string category)
    {
        MasteryLevel current = GetMasteryLevel(category);
        if (current == MasteryLevel.Usta) return current;
        int newLevel = (int)current + 1;
        SetLevel(category, newLevel);
        return (MasteryLevel)newLevel;
    }

    public int GetRewardMultiplier(MasteryLevel level)
    {
        switch (level)
        {
            case MasteryLevel.Novice: return 0;
            case MasteryLevel.Cirak:  return 1;
            case MasteryLevel.Kalfa:  return 2;
            case MasteryLevel.Usta:   return 3;
            default: return 0;
        }
    }

    public void CollectQuote(string quote)
    {
        if (!collectedQuotes.Contains(quote))
            collectedQuotes.Add(quote);
    }

    public bool HasCollectedQuote(string quote)
    {
        return collectedQuotes.Contains(quote);
    }

    public int GetTotalCollectedQuotes()
    {
        return collectedQuotes.Count;
    }

    public void AddStars(int amount)
    {
        stars += amount;
    }

    public bool HasEnoughStars(int amount)
    {
        return stars >= amount;
    }

    public static string GetMasteryDisplayName(MasteryLevel level)
    {
        switch (level)
        {
            case MasteryLevel.Novice: return "Hi\u00e7bir \u015eey Bilmiyor";
            case MasteryLevel.Cirak:  return "\u00c7\u0131rak";
            case MasteryLevel.Kalfa:  return "Kalfa";
            case MasteryLevel.Usta:   return "Usta";
            default: return "";
        }
    }
}
