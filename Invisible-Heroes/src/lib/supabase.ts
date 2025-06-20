import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error("Missing Supabase environment variables");
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Database types (you can update these based on your actual database schema)
export interface Story {
  id: number;
  subject: string;
  message: string;
  status: "pending" | "approved";
  submitted_at: string;
  created_at?: string;
  updated_at?: string;
}

// Database functions
export const storyService = {
  // Get all stories
  async getStories() {
    const { data, error } = await supabase
      .from("stories")
      .select("*")
      .order("submitted_at", { ascending: false });

    if (error) {
      console.error("Error fetching stories:", error);
      throw error;
    }

    return data as Story[];
  }, // Get only approved stories for public display
  async getApprovedStories() {
    const { data, error } = await supabase
      .from("stories")
      .select("*")
      .eq("status", "approved")
      .order("submitted_at", { ascending: false });

    if (error) {
      console.error("Error fetching approved stories:", error);
      throw error;
    }

    return data as Story[];
  },

  // Create a new story
  async createStory(story: Omit<Story, "id" | "created_at" | "updated_at">) {
    const { data, error } = await supabase
      .from("stories")
      .insert([story])
      .select()
      .single();

    if (error) {
      console.error("Error creating story:", error);
      throw error;
    }

    return data as Story;
  },

  // Update a story
  async updateStory(
    id: number,
    updates: Partial<Omit<Story, "id" | "created_at" | "updated_at">>
  ) {
    const { data, error } = await supabase
      .from("stories")
      .update(updates)
      .eq("id", id)
      .select()
      .single();

    if (error) {
      console.error("Error updating story:", error);
      throw error;
    }

    return data as Story;
  },

  // Delete a story
  async deleteStory(id: number) {
    const { error } = await supabase.from("stories").delete().eq("id", id);

    if (error) {
      console.error("Error deleting story:", error);
      throw error;
    }
  },
};
