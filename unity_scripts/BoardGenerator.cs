using System.Collections.Generic;
using UnityEngine;

public class BoardGenerator : MonoBehaviour
{
    [Header("Tile Settings")]
    public GameObject tilePrefab;
    public float tileSize = 1f;
    public float spacing = 0.1f;

    [Header("Label Settings")]
    public float labelHeight = 0.6f;
    public int labelFontSize = 14;

    private readonly List<BoardTileData> boardTiles = new List<BoardTileData>();

    private void DefineTiles()
    {
        boardTiles.Clear();

        // --- BOTTOM ROW (0-6) ---
        boardTiles.Add(new BoardTileData("0",  "BA\u015eLANGI\u00c7",                          0,  TileType.Start,      "",             Difficulty.Easy));
        boardTiles.Add(new BoardTileData("1",  "T\u00fcrk Edebiyat\u0131nda \u0130lkler",      1,  TileType.Category,   "turkEdebiyatindaIlkler", Difficulty.Easy));
        boardTiles.Add(new BoardTileData("2",  "Edebi Sanatlar",                                2,  TileType.Category,   "edebiSanatlar",           Difficulty.Easy));
        boardTiles.Add(new BoardTileData("3",  "\u015eANS",                                     3,  TileType.Chance,     "",             Difficulty.Medium));
        boardTiles.Add(new BoardTileData("4",  "Eser-Karakter",                                4,  TileType.Category,   "eserKarakter",            Difficulty.Easy));
        boardTiles.Add(new BoardTileData("5",  "Edebiyat Ak\u0131mlar\u0131",                   5,  TileType.Category,   "edebiyatAkimlari",        Difficulty.Easy));
        boardTiles.Add(new BoardTileData("6",  "\u0130MZA G\u00dcN\u00dc",                     6,  TileType.SigningDay, "",             Difficulty.Medium));

        // --- LEFT COLUMN (7-13) ---
        boardTiles.Add(new BoardTileData("7",  "Ben Kimim?",           7,  TileType.Category, "benKimim",    Difficulty.Medium));
        boardTiles.Add(new BoardTileData("8",  "Te\u015fvik",          8,  TileType.Tesvik,   "tesvik",      Difficulty.Medium));
        boardTiles.Add(new BoardTileData("9",  "T\u00fcrk Edebiyat\u0131nda \u0130lkler", 9, TileType.Category, "turkEdebiyatindaIlkler", Difficulty.Medium));
        boardTiles.Add(new BoardTileData("10", "KADER",                10, TileType.Fate,     "",            Difficulty.Medium));
        boardTiles.Add(new BoardTileData("11", "Edebi Sanatlar",       11, TileType.Category, "edebiSanatlar", Difficulty.Medium));
        boardTiles.Add(new BoardTileData("12", "Eser-Karakter",        12, TileType.Category, "eserKarakter",  Difficulty.Medium));
        boardTiles.Add(new BoardTileData("13", "KIRAATHANE",           13, TileType.Shop,     "",            Difficulty.Medium));

        // --- TOP ROW (14-19) ---
        boardTiles.Add(new BoardTileData("14", "Edebiyat Ak\u0131mlar\u0131", 14, TileType.Category, "edebiyatAkimlari",   Difficulty.Medium));
        boardTiles.Add(new BoardTileData("15", "Ben Kimim?",                   15, TileType.Category, "benKimim",           Difficulty.Medium));
        boardTiles.Add(new BoardTileData("16", "\u015eANS",                    16, TileType.Chance,   "",                   Difficulty.Medium));
        boardTiles.Add(new BoardTileData("17", "Te\u015fvik",                  17, TileType.Tesvik,   "tesvik",             Difficulty.Medium));
        boardTiles.Add(new BoardTileData("18", "T\u00fcrk Edebiyat\u0131nda \u0130lkler", 18, TileType.Category, "turkEdebiyatindaIlkler", Difficulty.Medium));
        boardTiles.Add(new BoardTileData("19", "K\u00dcT\u00dcPHANE",         19, TileType.Library,  "",                   Difficulty.Hard));

        // --- RIGHT COLUMN (20-25) ---
        boardTiles.Add(new BoardTileData("20", "Edebi Sanatlar",       20, TileType.Category, "edebiSanatlar",    Difficulty.Hard));
        boardTiles.Add(new BoardTileData("21", "Eser-Karakter",        21, TileType.Category, "eserKarakter",     Difficulty.Hard));
        boardTiles.Add(new BoardTileData("22", "KADER",                22, TileType.Fate,     "",                 Difficulty.Medium));
        boardTiles.Add(new BoardTileData("23", "Edebiyat Ak\u0131mlar\u0131", 23, TileType.Category, "edebiyatAkimlari", Difficulty.Hard));
        boardTiles.Add(new BoardTileData("24", "Ben Kimim?",           24, TileType.Category, "benKimim",         Difficulty.Hard));
        boardTiles.Add(new BoardTileData("25", "Te\u015fvik",          25, TileType.Tesvik,   "tesvik",           Difficulty.Hard));
    }

    private Vector3 GetWorldPosition(int index)
    {
        float step = tileSize + spacing;

        // BOTTOM ROW (0-6): col 6→0, row 0
        if (index >= 0 && index <= 6)
            return new Vector3((6 - index) * step, 0f, 0f);

        // LEFT COLUMN (7-13): col 0, row 1→7
        if (index >= 7 && index <= 13)
            return new Vector3(0f, 0f, (index - 6) * step);

        // TOP ROW (14-19): col 1→6, row 7
        if (index >= 14 && index <= 19)
            return new Vector3((index - 13) * step, 0f, 7f * step);

        // RIGHT COLUMN (20-25): col 6, row 6→1
        if (index >= 20 && index <= 25)
            return new Vector3(6f * step, 0f, (26 - index) * step);

        return Vector3.zero;
    }

    [ContextMenu("Generate Board")]
    public void GenerateBoard()
    {
        DefineTiles();

        for (int i = transform.childCount - 1; i >= 0; i--)
            DestroyImmediate(transform.GetChild(i).gameObject);

        float step = tileSize + spacing;

        for (int i = 0; i < boardTiles.Count; i++)
        {
            BoardTileData tileData = boardTiles[i];
            Vector3 pos = GetWorldPosition(i);

            GameObject tileObj = Instantiate(tilePrefab, pos, Quaternion.identity, transform);
            tileObj.name = $"Tile_{i}_{tileData.name}";

            TileLabel label = tileObj.GetComponent<TileLabel>();
            if (label == null)
                label = tileObj.AddComponent<TileLabel>();

            label.tileName = tileData.name;
            label.tileIndex = i;
            label.tileType = tileData.type;
            label.difficulty = tileData.difficulty;
        }
    }

    public BoardTileData GetTile(int index)
    {
        if (index < 0 || index >= boardTiles.Count) return null;
        return boardTiles[index];
    }

    public int TileCount => boardTiles.Count;
}
