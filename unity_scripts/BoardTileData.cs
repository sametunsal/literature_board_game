using System;

public enum TileType
{
    Start,
    Category,
    Corner,
    Shop,
    Collection,
    Library,
    SigningDay,
    Chance,
    Fate,
    Tesvik
}

public enum Difficulty
{
    Easy,
    Medium,
    Hard
}

[System.Serializable]
public class BoardTileData
{
    public string id;
    public string name;
    public int position;
    public TileType type;
    public string category;
    public Difficulty difficulty = Difficulty.Medium;

    public BoardTileData() { }

    public BoardTileData(string id, string name, int position, TileType type,
                         string category = null, Difficulty difficulty = Difficulty.Medium)
    {
        this.id = id;
        this.name = name;
        this.position = position;
        this.type = type;
        this.category = category;
        this.difficulty = difficulty;
    }

    public static string GetTileTypeDisplayName(TileType tileType)
    {
        switch (tileType)
        {
            case TileType.Start:      return "Ba\u015flang\u0131\u00e7";
            case TileType.Category:   return "Kategori";
            case TileType.Corner:     return "K\u00f6\u015fe";
            case TileType.Shop:       return "K\u0131raathane";
            case TileType.Collection: return "Koleksiyon";
            case TileType.Library:    return "K\u00fct\u00fcphane";
            case TileType.SigningDay: return "\u0130mza G\u00fcn\u00fc";
            case TileType.Chance:     return "\u015eans";
            case TileType.Fate:       return "Kader";
            case TileType.Tesvik:     return "Te\u015fvik";
            default: return "";
        }
    }

    public static string GetDifficultyDisplayName(Difficulty diff)
    {
        switch (diff)
        {
            case Difficulty.Easy:   return "Kolay";
            case Difficulty.Medium: return "Orta";
            case Difficulty.Hard:   return "Zor";
            default: return "";
        }
    }
}
